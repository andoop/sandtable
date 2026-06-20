import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/connection.dart';
import 'models/document.dart';
import 'models/message.dart';
import 'models/session.dart';

/// Thrown when the runtime server returns a non-2xx response.
class SandtableApiException implements Exception {
  SandtableApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thrown when the server rejects the pairing token (HTTP 401). Signals that the
/// stored connection is no longer valid and the user must pair again.
class SandtableAuthException extends SandtableApiException {
  SandtableAuthException() : super('配对已失效，请重新连接');
}

/// Typed REST client for the Sandtable runtime server. Stateless beyond the
/// [connection] it is constructed with.
class SandtableApi {
  SandtableApi(this.connection, {http.Client? client})
      : _client = client ?? http.Client();

  final SandtableConnection connection;
  final http.Client _client;

  // --- pairing (static; no connection yet) -------------------------------

  /// Pair with a 4-digit code printed by `/sandtable-mobile-start`.
  static Future<SandtableConnection> pairByCode({
    required Uri baseUrl,
    required String code,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.post(
        baseUrl.resolve('/pair/by-code'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'code': code}),
      );
      if (response.statusCode >= 400) {
        throw SandtableApiException('配对失败 (${response.statusCode})');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SandtableConnection(
        baseUrl: Uri.parse(json['url'] as String? ?? baseUrl.toString()),
        token: json['token'] as String,
      );
    } finally {
      if (client == null) httpClient.close();
    }
  }

  // --- authenticated requests --------------------------------------------

  Uri _withToken(String path) => connection.baseUrl
      .resolve(path)
      .replace(queryParameters: {'token': connection.token});

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await _client.get(_withToken(path));
    if (response.statusCode == 401) throw SandtableAuthException();
    if (response.statusCode >= 400) {
      throw SandtableApiException('请求失败 (${response.statusCode}): $path');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Lightweight liveness probe used by the connection watchdog.
  Future<bool> healthy() async {
    try {
      final response = await _client
          .get(connection.baseUrl.resolve('/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<RuntimeSession>> listSessions() async {
    final json = await _getJson('/sessions');
    return (json['sessions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RuntimeSession.fromJson)
        .toList();
  }

  Future<RuntimeSession> readSession(String sessionId) async {
    final json = await _getJson('/sessions/$sessionId');
    return RuntimeSession.fromJson(json['session'] as Map<String, dynamic>);
  }

  Future<void> deleteSession(String sessionId) async {
    final response = await _client.delete(_withToken('/sessions/$sessionId'));
    if (response.statusCode == 401) throw SandtableAuthException();
    if (response.statusCode >= 400) {
      throw SandtableApiException('删除失败 (${response.statusCode})');
    }
  }

  Future<List<ConversationMessage>> readConversation(String sessionId) async {
    final json = await _getJson('/sessions/$sessionId/messages');
    return (json['messages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ConversationMessage.fromJson)
        .toList();
  }

  Future<SandtableDocument> readDocument(String sessionId, String name) async {
    final json = await _getJson('/sessions/$sessionId/documents/$name');
    return SandtableDocument.fromJson(name, json);
  }

  Future<void> sendMessage(
    String sessionId, {
    required String text,
    String target = 'conversation',
    String kind = 'chat',
  }) async {
    final response = await _client.post(
      connection.baseUrl.resolve('/sessions/$sessionId/messages'),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'token': connection.token,
        'text': text,
        'target': target,
        'kind': kind,
      }),
    );
    if (response.statusCode == 401) throw SandtableAuthException();
    if (response.statusCode >= 400) {
      throw SandtableApiException('发送失败 (${response.statusCode})');
    }
  }

  void dispose() => _client.close();
}
