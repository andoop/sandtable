/// Identity of a coding agent driving a session (Codex / Cursor / Claude Code / ...).
class AgentIdentity {
  const AgentIdentity({
    required this.id,
    required this.kind,
    required this.name,
  });

  final String id;
  final String kind;
  final String name;

  factory AgentIdentity.fromJson(Map<String, dynamic> json) {
    return AgentIdentity(
      id: json['id'] as String? ?? '',
      kind: (json['kind'] as String? ?? 'custom').toLowerCase(),
      name: json['name'] as String? ?? 'Agent',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'kind': kind, 'name': name};
}
