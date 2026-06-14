/// A Sandtable feature document snapshot (state / prd / tests / plan / ...).
class SandtableDocument {
  const SandtableDocument({
    required this.name,
    required this.status,
    this.content = '',
  });

  final String name;
  final String status; // 'ok' | 'missing'
  final String content;

  bool get isMissing => status == 'missing';

  factory SandtableDocument.fromJson(String name, Map<String, dynamic> json) {
    return SandtableDocument(
      name: json['name'] as String? ?? name,
      status: json['status'] as String? ?? 'missing',
      content: json['content'] as String? ?? '',
    );
  }
}
