import 'package:flutter/material.dart';

/// The kinds of message a developer can send from the conversation.
enum ComposerMode { chat, answer, confirmation }

/// Bottom chat input with a send button and a mode menu (chat / answer /
/// confirm). Mirrors the affordances of a polished messaging app.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.sending = false,
  });

  /// Returns the future of the send op so the composer can show progress.
  final Future<void> Function(String text, ComposerMode mode) onSend;
  final bool sending;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ComposerMode _mode = ComposerMode.chat;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _hint {
    switch (_mode) {
      case ComposerMode.answer:
        return '输入回答…';
      case ComposerMode.confirmation:
        return '输入确认内容…';
      case ComposerMode.chat:
        return '发送消息给这个会话…';
    }
  }

  String get _modeLabel {
    switch (_mode) {
      case ComposerMode.answer:
        return '回答';
      case ComposerMode.confirmation:
        return '确认';
      case ComposerMode.chat:
        return '消息';
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.sending) return;
    await widget.onSend(text, _mode);
    if (mounted) {
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSend = _controller.text.trim().isNotEmpty && !widget.sending;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
              top: BorderSide(color: scheme.outlineVariant.withOpacity(0.6))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PopupMenuButton<ComposerMode>(
              tooltip: '发送方式',
              initialValue: _mode,
              onSelected: (mode) => setState(() => _mode = mode),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => const [
                PopupMenuItem(value: ComposerMode.chat, child: Text('普通消息')),
                PopupMenuItem(value: ComposerMode.answer, child: Text('作为回答')),
                PopupMenuItem(
                    value: ComposerMode.confirmation, child: Text('作为确认')),
              ],
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_modeLabel,
                        style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.arrow_drop_down,
                        color: scheme.onSurfaceVariant, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _hint,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(enabled: canSend, busy: widget.sending, onTap: _submit),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton(
      {required this.enabled, required this.busy, required this.onTap});

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: enabled ? scheme.primary : scheme.surfaceVariant,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(Icons.arrow_upward_rounded,
                  color: enabled ? Colors.white : scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
