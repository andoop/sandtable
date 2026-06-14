import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/time_format.dart';
import '../../data/models/message.dart';

/// Renders one conversation entry. Chat/answer/confirmation messages render as
/// left/right bubbles; phase/document/status/system entries render as centered
/// inline notices so the transcript reads like a mature messaging app.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.onRetry});

  final ConversationMessage message;
  final VoidCallback? onRetry;

  bool get _isNotice =>
      message.role == MessageRole.system ||
      message.kind == MessageKind.phase ||
      message.kind == MessageKind.document ||
      message.kind == MessageKind.status ||
      message.kind == MessageKind.paired ||
      message.kind == MessageKind.stop;

  @override
  Widget build(BuildContext context) {
    if (_isNotice) return _notice(context);
    return _bubble(context);
  }

  Widget _notice(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_noticeIcon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _noticeText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _noticeIcon {
    switch (message.kind) {
      case MessageKind.phase:
        return Icons.flag_rounded;
      case MessageKind.document:
        return Icons.description_outlined;
      case MessageKind.paired:
        return Icons.link_rounded;
      case MessageKind.stop:
        return Icons.stop_circle_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String get _noticeText {
    switch (message.kind) {
      case MessageKind.phase:
        final phase = message.payload['phase'];
        return phase != null ? '阶段更新 · $phase' : message.text;
      case MessageKind.document:
        return message.text;
      default:
        return message.text;
    }
  }

  Widget _bubble(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = message.isFromMobile;
    final bg = mine ? scheme.primary : Theme.of(context).cardColor;
    final fg = mine ? Colors.white : scheme.onSurface;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(mine ? 16 : 4),
      bottomRight: Radius.circular(mine ? 4 : 16),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!mine && (message.agentName ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                message.agentName!,
                style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              border: mine
                  ? null
                  : Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.kind == MessageKind.answer ||
                    message.kind == MessageKind.confirmation)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.kind == MessageKind.answer ? '回答' : '确认',
                      style: TextStyle(
                        color: (mine ? Colors.white : scheme.primary)
                            .withOpacity(0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                MarkdownBody(
                  data: message.text,
                  softLineBreak: true,
                  styleSheet: _markdownStyle(context, fg, mine),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: _statusLine(context, scheme),
          ),
        ],
      ),    );
  }

  Widget _statusLine(BuildContext context, ColorScheme scheme) {
    final time = clockTime(message.createdAt);
    final style = TextStyle(color: scheme.onSurfaceVariant, fontSize: 10.5);
    if (message.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 13, color: scheme.error),
          const SizedBox(width: 4),
          Text('发送失败', style: TextStyle(color: scheme.error, fontSize: 10.5)),
          if (onRetry != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRetry,
              child: Text('重试',
                  style: TextStyle(
                      color: scheme.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(time, style: style),
        if (message.isFromMobile) ...[
          const SizedBox(width: 4),
          Icon(
            message.pending ? Icons.schedule_rounded : Icons.done_rounded,
            size: 12,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  /// Markdown styling tuned for a chat bubble — compact spacing, side-aware
  /// colors (white on the user's blue bubble), readable code blocks.
  MarkdownStyleSheet _markdownStyle(BuildContext context, Color fg, bool mine) {
    final scheme = Theme.of(context).colorScheme;
    final codeBg =
        mine ? Colors.white.withOpacity(0.18) : scheme.surfaceVariant.withOpacity(0.7);
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final body = TextStyle(color: fg, fontSize: 15, height: 1.4);
    return base.copyWith(
      p: body,
      listBullet: body,
      h1: body.copyWith(fontSize: 19, fontWeight: FontWeight.w800),
      h2: body.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
      h3: body.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
      strong: body.copyWith(fontWeight: FontWeight.w700),
      em: body.copyWith(fontStyle: FontStyle.italic),
      a: body.copyWith(
          color: mine ? Colors.white : scheme.primary,
          decoration: TextDecoration.underline),
      code: TextStyle(
        color: fg,
        fontFamily: 'monospace',
        fontSize: 13,
        backgroundColor: codeBg,
      ),
      codeblockPadding: const EdgeInsets.all(10),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: BoxDecoration(
        color: (mine ? Colors.white : scheme.primary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      blockSpacing: 6,
    );
  }
}
