import 'agent.dart';

/// Lifecycle status of a session, mirrored from the runtime server.
enum SessionStatus { active, idle, blocked, done, stopped }

SessionStatus _statusFromString(String value) {
  switch (value) {
    case 'active':
      return SessionStatus.active;
    case 'blocked':
      return SessionStatus.blocked;
    case 'done':
      return SessionStatus.done;
    case 'stopped':
      return SessionStatus.stopped;
    case 'idle':
    default:
      return SessionStatus.idle;
  }
}

String _statusToString(SessionStatus status) {
  switch (status) {
    case SessionStatus.active:
      return 'active';
    case SessionStatus.blocked:
      return 'blocked';
    case SessionStatus.done:
      return 'done';
    case SessionStatus.stopped:
      return 'stopped';
    case SessionStatus.idle:
      return 'idle';
  }
}

/// A single agent working on a single feature. The phone manages many of these
/// concurrently, across different agents and workspaces.
class RuntimeSession {
  const RuntimeSession({
    required this.id,
    required this.title,
    required this.feature,
    required this.workspace,
    required this.agent,
    required this.status,
    required this.blocked,
    required this.paired,
    required this.lastActivityAt,
    this.phase,
    this.summary,
  });

  final String id;
  final String title;
  final String feature;
  final String workspace;
  final AgentIdentity agent;
  final SessionStatus status;
  final String? phase;
  final bool blocked;
  final bool paired;
  final DateTime lastActivityAt;
  final String? summary;

  factory RuntimeSession.fromJson(Map<String, dynamic> json) {
    return RuntimeSession(
      id: json['id'] as String? ?? '',
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : (json['feature'] as String? ?? 'Untitled'),
      feature: json['feature'] as String? ?? '',
      workspace: json['workspace'] as String? ?? '',
      agent: AgentIdentity.fromJson(
          (json['agent'] as Map<String, dynamic>?) ?? const {}),
      status: _statusFromString(json['status'] as String? ?? 'idle'),
      phase: json['phase'] as String?,
      blocked: json['blocked'] as bool? ?? false,
      paired: json['paired'] as bool? ?? false,
      lastActivityAt:
          DateTime.tryParse(json['lastActivityAt'] as String? ?? '')?.toLocal() ??
              DateTime.fromMillisecondsSinceEpoch(0),
      summary: (json['summary'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'feature': feature,
        'workspace': workspace,
        'agent': agent.toJson(),
        'status': _statusToString(status),
        'phase': phase,
        'blocked': blocked,
        'paired': paired,
        'lastActivityAt': lastActivityAt.toUtc().toIso8601String(),
        'summary': summary,
      };
}
