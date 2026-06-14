/// Who authored a conversation message.
enum MessageRole { agent, mobile, system }

/// Semantic kind, used to choose how a message bubble renders.
enum MessageKind {
  chat,
  phase,
  question,
  answer,
  confirmation,
  document,
  status,
  paired,
  stop,
  unknown,
}

MessageRole _roleFromString(String value) {
  switch (value) {
    case 'agent':
      return MessageRole.agent;
    case 'mobile':
      return MessageRole.mobile;
    case 'system':
    default:
      return MessageRole.system;
  }
}

MessageKind _kindFromString(String value) {
  switch (value) {
    case 'chat':
      return MessageKind.chat;
    case 'phase':
      return MessageKind.phase;
    case 'question':
      return MessageKind.question;
    case 'answer':
      return MessageKind.answer;
    case 'confirmation':
      return MessageKind.confirmation;
    case 'document':
      return MessageKind.document;
    case 'status':
      return MessageKind.status;
    case 'paired':
      return MessageKind.paired;
    case 'stop':
      return MessageKind.stop;
    default:
      return MessageKind.unknown;
  }
}

/// A durable entry in a session conversation transcript.
class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.sessionId,
    required this.feature,
    required this.role,
    required this.kind,
    required this.text,
    required this.createdAt,
    this.agentName,
    this.payload = const {},
    this.pending = false,
    this.failed = false,
  });

  final String id;
  final String sessionId;
  final String feature;
  final MessageRole role;
  final MessageKind kind;
  final String text;
  final DateTime createdAt;
  final String? agentName;
  final Map<String, dynamic> payload;

  /// Client-only: the optimistic message is still being delivered to the server.
  final bool pending;

  /// Client-only: delivery failed and the message can be retried.
  final bool failed;

  bool get isFromMobile => role == MessageRole.mobile;
  bool get isLocal => id.startsWith('local_');

  ConversationMessage copyWith({bool? pending, bool? failed}) {
    return ConversationMessage(
      id: id,
      sessionId: sessionId,
      feature: feature,
      role: role,
      kind: kind,
      text: text,
      createdAt: createdAt,
      agentName: agentName,
      payload: payload,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
    );
  }

  /// Build an optimistic local message shown immediately on send.
  factory ConversationMessage.local({
    required String id,
    required String sessionId,
    required String feature,
    required String text,
    required MessageKind kind,
  }) {
    return ConversationMessage(
      id: id,
      sessionId: sessionId,
      feature: feature,
      role: MessageRole.mobile,
      kind: kind,
      text: text,
      createdAt: DateTime.now(),
      pending: true,
    );
  }

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    final agent = json['agent'] as Map<String, dynamic>?;
    return ConversationMessage(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      feature: json['feature'] as String? ?? '',
      role: _roleFromString(json['role'] as String? ?? 'system'),
      kind: _kindFromString(json['kind'] as String? ?? 'chat'),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      agentName: agent?['name'] as String?,
      payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
