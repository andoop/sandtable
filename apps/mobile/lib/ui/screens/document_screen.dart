import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../data/models/document.dart';
import '../widgets/empty_state.dart';

/// Read-only viewer for a Sandtable feature document, rendered as Markdown.
/// YAML frontmatter (the `--- ... ---` block at the top of `state.md`) is shown
/// as a compact metadata card; the rest renders as formatted Markdown. A toggle
/// switches to raw source for copy/paste.
class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key, required this.document});

  final SandtableDocument document;

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  bool _showSource = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    return Scaffold(
      appBar: AppBar(
        title: Text(doc.name),
        actions: [
          if (!doc.isMissing)
            IconButton(
              tooltip: _showSource ? '渲染视图' : '源码视图',
              icon: Icon(_showSource
                  ? Icons.article_outlined
                  : Icons.code_rounded),
              onPressed: () => setState(() => _showSource = !_showSource),
            ),
        ],
      ),
      body: doc.isMissing
          ? const EmptyState(
              icon: Icons.note_add_outlined,
              title: '尚未生成',
              message: '该文档将在 Agent 推进到对应阶段后生成。',
            )
          : _showSource
              ? _source(context, doc.content)
              : _rendered(context, doc.content),
    );
  }

  Widget _source(BuildContext context, String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        content,
        style: const TextStyle(
            fontFamily: 'monospace', fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _rendered(BuildContext context, String content) {
    final parts = _splitFrontmatter(content);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (parts.frontmatter.isNotEmpty) ...[
          _Frontmatter(entries: parts.frontmatter),
          const SizedBox(height: 16),
        ],
        MarkdownBody(
          data: parts.body.isEmpty ? '_（空文档）_' : parts.body,
          selectable: true,
          styleSheet: _styleSheet(context),
        ),
      ],
    );
  }

  MarkdownStyleSheet _styleSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    return base.copyWith(
      p: base.p?.copyWith(fontSize: 14.5, height: 1.55),
      h1: base.h1?.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
      h2: base.h2?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
      h3: base.h3?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
      code: base.code?.copyWith(
        backgroundColor: scheme.surfaceVariant.withOpacity(0.6),
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      blockquoteDecoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border(
            left: BorderSide(color: scheme.primary.withOpacity(0.5), width: 3)),
      ),
    );
  }

  _DocParts _splitFrontmatter(String content) {
    final text = content.replaceAll('\r\n', '\n');
    if (!text.startsWith('---')) return _DocParts(const [], text.trim());
    final end = text.indexOf('\n---', 3);
    if (end < 0) return _DocParts(const [], text.trim());
    final block = text.substring(3, end).trim();
    final body = text.substring(end + 4).trim();
    final entries = <MapEntry<String, String>>[];
    for (final line in block.split('\n')) {
      final idx = line.indexOf(':');
      if (idx <= 0) continue;
      final key = line.substring(0, idx).trim();
      final value = line.substring(idx + 1).trim();
      if (key.isNotEmpty) entries.add(MapEntry(key, value));
    }
    return _DocParts(entries, body);
  }
}

class _DocParts {
  const _DocParts(this.frontmatter, this.body);
  final List<MapEntry<String, String>> frontmatter;
  final String body;
}

class _Frontmatter extends StatelessWidget {
  const _Frontmatter({required this.entries});
  final List<MapEntry<String, String>> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(entry.value,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
