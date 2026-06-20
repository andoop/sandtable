import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/connection.dart';
import 'models/session.dart';

/// A persisted server connection (one per repo / runtime instance).
class StoredConnection {
  StoredConnection({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.token,
  });

  final String id;
  final String label;
  final Uri baseUrl;
  final String token;

  SandtableConnection get connection =>
      SandtableConnection(baseUrl: baseUrl, token: token);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'url': baseUrl.toString(),
        'token': token,
      };

  factory StoredConnection.fromJson(Map<String, dynamic> json) {
    return StoredConnection(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      baseUrl: Uri.parse(json['url'] as String),
      token: json['token'] as String,
    );
  }
}

/// Per-connection session-list cache, so each server cold-starts instantly with
/// its own last-known sessions (no cross-server collision).
abstract class SessionCache {
  Future<List<RuntimeSession>> load();
  Future<void> save(List<RuntimeSession> sessions);
  Future<void> clear();
}

/// Per-connection record of "how far the user has read" each session, so the
/// list can flag sessions with activity newer than the last time they were
/// opened. Keyed by sessionId → last-read activity time (UTC millis).
abstract class ReadMarksCache {
  Future<Map<String, DateTime>> load();
  Future<void> save(Map<String, DateTime> marks);
  Future<void> clear();
}

/// Stores the list of connected servers and their cached sessions. Replaces the
/// old single-connection store so the app can manage multiple repos/servers.
class ConnectionsRepository {
  static const String _connectionsKey = 'sandtable.connections';
  static const String _sessionsPrefix = 'sandtable.sessions.';
  static const String _readMarksPrefix = 'sandtable.read.';

  Future<List<StoredConnection>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_connectionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(StoredConnection.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<StoredConnection> connections) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _connectionsKey,
      jsonEncode(connections.map((c) => c.toJson()).toList()),
    );
  }

  SessionCache cacheFor(String connectionId) =>
      _PrefsSessionCache('$_sessionsPrefix$connectionId');

  ReadMarksCache readMarksFor(String connectionId) =>
      _PrefsReadMarksCache('$_readMarksPrefix$connectionId');
}

class _PrefsSessionCache implements SessionCache {
  _PrefsSessionCache(this._key);
  final String _key;

  @override
  Future<List<RuntimeSession>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(RuntimeSession.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> save(List<RuntimeSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class _PrefsReadMarksCache implements ReadMarksCache {
  _PrefsReadMarksCache(this._key);
  final String _key;

  @override
  Future<Map<String, DateTime>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final marks = <String, DateTime>{};
      decoded.forEach((id, millis) {
        if (millis is int) {
          marks[id] = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
        }
      });
      return marks;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> save(Map<String, DateTime> marks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(marks.map(
          (id, time) => MapEntry(id, time.toUtc().millisecondsSinceEpoch))),
    );
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
