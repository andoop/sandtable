import 'package:flutter_test/flutter_test.dart';
import 'package:sandtable_mobile_review/data/models/connection.dart';
import 'package:sandtable_mobile_review/data/models/document.dart';
import 'package:sandtable_mobile_review/data/models/message.dart';
import 'package:sandtable_mobile_review/data/models/session.dart';

void main() {
  test('parses missing document state', () {
    final doc = SandtableDocument.fromJson('plan', {'status': 'missing'});
    expect(doc.name, 'plan');
    expect(doc.isMissing, isTrue);
    expect(doc.content, '');
  });

  test('parses pairing payload (device-level, token only)', () {
    final connection = SandtableConnection.fromPairingPayload(
      'sandtable://pair?url=http%3A%2F%2F127.0.0.1%3A8765&token=abc&feature=f1',
    );
    expect(connection.baseUrl.toString(), 'http://127.0.0.1:8765');
    expect(connection.token, 'abc');
  });

  test('rejects malformed pairing payload', () {
    expect(
      () => SandtableConnection.fromPairingPayload('https://example.com'),
      throwsA(isA<FormatException>()),
    );
  });

  test('parses runtime sessions with status enum', () {
    final session = RuntimeSession.fromJson({
      'id': 'sess_1',
      'title': 'Plan review',
      'feature': 'feature-a',
      'workspace': '/tmp/repo',
      'agent': {'id': 'codex-1', 'kind': 'codex', 'name': 'Codex'},
      'status': 'blocked',
      'phase': 'PLAN',
      'blocked': true,
      'paired': true,
      'lastActivityAt': '2026-06-14T00:00:01Z',
    });
    expect(session.agent.kind, 'codex');
    expect(session.phase, 'PLAN');
    expect(session.status, SessionStatus.blocked);
  });

  test('parses conversation message with role and kind', () {
    final message = ConversationMessage.fromJson({
      'id': 'msg_1',
      'sessionId': 'sess_1',
      'feature': 'feature-a',
      'role': 'agent',
      'kind': 'phase',
      'text': 'Phase PLAN',
      'createdAt': '2026-06-14T00:00:01Z',
      'agent': {'name': 'Codex'},
      'payload': {'phase': 'PLAN'},
    });
    expect(message.role, MessageRole.agent);
    expect(message.kind, MessageKind.phase);
    expect(message.isFromMobile, isFalse);
    expect(message.agentName, 'Codex');
  });
}
