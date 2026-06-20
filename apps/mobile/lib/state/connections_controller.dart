import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/connections_repository.dart';
import '../data/models/connection.dart';
import '../data/models/session.dart';
import '../data/runtime_stream.dart';
import 'session_store.dart';

/// One managed server connection plus its live [SessionStore].
class ManagedConnection {
  ManagedConnection({required this.stored, required this.store});

  final StoredConnection stored;
  final SessionStore store;

  String get id => stored.id;
  String get label => stored.label;
}

/// A session paired with the connection it belongs to, for the aggregated list.
class AggregatedSession {
  AggregatedSession(this.session, this.connection);
  final RuntimeSession session;
  final ManagedConnection connection;
}

/// Top-level controller managing every connected server. Provides a single
/// aggregated view across repos/servers while keeping each server's stream and
/// state isolated in its own [SessionStore].
class ConnectionsController extends ChangeNotifier {
  ConnectionsController({ConnectionsRepository? repository})
      : _repo = repository ?? ConnectionsRepository();

  final ConnectionsRepository _repo;
  final List<ManagedConnection> _connections = [];

  bool _booting = true;
  String? _notice;

  bool get isBooting => _booting;
  bool get isEmpty => _connections.isEmpty;
  List<ManagedConnection> get connections => List.unmodifiable(_connections);

  /// A transient message (e.g. "a server was removed because its pairing expired").
  String? consumeNotice() {
    final n = _notice;
    _notice = null;
    return n;
  }

  /// Sessions across all servers, newest activity first.
  List<AggregatedSession> get sessions {
    final all = <AggregatedSession>[];
    for (final managed in _connections) {
      for (final session in managed.store.sessions) {
        all.add(AggregatedSession(session, managed));
      }
    }
    all.sort((a, b) =>
        b.session.lastActivityAt.compareTo(a.session.lastActivityAt));
    return all;
  }

  int get activeSessionCount => sessions
      .where((s) =>
          s.session.status == SessionStatus.active ||
          s.session.status == SessionStatus.blocked)
      .length;

  /// Total sessions with unseen activity across all servers, for an at-a-glance
  /// badge on the list.
  int get unreadSessionCount =>
      _connections.fold(0, (sum, c) => sum + c.store.unreadCount);

  /// Worst connection status across all servers, for the global banner.
  StreamStatus get aggregateStatus {
    if (_connections.isEmpty) return StreamStatus.disconnected;
    final statuses = _connections.map((c) => c.store.streamStatus.value);
    if (statuses.every((s) => s == StreamStatus.live)) return StreamStatus.live;
    if (statuses.any((s) => s == StreamStatus.live)) {
      // Some live, some not — still reconnecting overall.
      return StreamStatus.reconnecting;
    }
    if (statuses.any((s) =>
        s == StreamStatus.connecting || s == StreamStatus.reconnecting)) {
      return StreamStatus.reconnecting;
    }
    return StreamStatus.disconnected;
  }

  ManagedConnection? connectionById(String id) {
    for (final c in _connections) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> init() async {
    final stored = await _repo.load();
    for (final connection in stored) {
      _attach(connection);
    }
    _booting = false;
    notifyListeners();
    for (final managed in _connections) {
      unawaited(managed.store.init());
    }
  }

  /// Add (or re-pair) a server. Connections are de-duped by base URL.
  Future<void> addConnection(SandtableConnection connection,
      {String? label}) async {
    final existing = _connections
        .where((c) => c.stored.baseUrl == connection.baseUrl)
        .toList();
    for (final dup in existing) {
      await _detach(dup, clearCache: false);
    }
    final id = existing.isNotEmpty
        ? existing.first.id
        : 'conn_${DateTime.now().microsecondsSinceEpoch}';
    final stored = StoredConnection(
      id: id,
      label: label ?? connection.label,
      baseUrl: connection.baseUrl,
      token: connection.token,
    );
    final managed = _attach(stored);
    await _persist();
    notifyListeners();
    await managed.store.init();
  }

  Future<void> removeConnection(String id) async {
    final managed = connectionById(id);
    if (managed == null) return;
    await _detach(managed, clearCache: true);
    await _persist();
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait(_connections.map((c) => c.store.refreshSessions()));
  }

  Future<void> reconnectAll() async {
    await Future.wait(_connections.map((c) => c.store.reconnect()));
  }

  // --- internals ----------------------------------------------------------

  ManagedConnection _attach(StoredConnection stored) {
    final store = SessionStore(
      id: stored.id,
      connection: stored.connection,
      cache: _repo.cacheFor(stored.id),
      readMarks: _repo.readMarksFor(stored.id),
    );
    final managed = ManagedConnection(stored: stored, store: store);
    store.addListener(() => _onStoreChanged(managed));
    _connections.add(managed);
    return managed;
  }

  Future<void> _detach(ManagedConnection managed, {required bool clearCache}) async {
    _connections.remove(managed);
    managed.store.dispose();
    if (clearCache) {
      await _repo.cacheFor(managed.id).clear();
      await _repo.readMarksFor(managed.id).clear();
    }
  }

  void _onStoreChanged(ManagedConnection managed) {
    if (managed.store.unauthorized && connectionById(managed.id) != null) {
      // The server rejected this token; drop just this connection.
      _notice = '“${managed.label}” 的配对已失效，已移除该服务器';
      unawaited(removeConnection(managed.id));
      return;
    }
    notifyListeners();
  }

  Future<void> _persist() =>
      _repo.save(_connections.map((c) => c.stored).toList());

  @override
  void dispose() {
    for (final managed in _connections) {
      managed.store.dispose();
    }
    _connections.clear();
    super.dispose();
  }
}
