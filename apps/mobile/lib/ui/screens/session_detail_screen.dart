import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/agent_visuals.dart';
import '../../data/models/message.dart';
import '../../data/models/session.dart';
import '../../state/session_store.dart';
import '../widgets/agent_avatar.dart';
import '../widgets/chat_composer.dart';
import '../widgets/empty_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/status_badge.dart';
import '../widgets/typing_indicator.dart';
import 'document_screen.dart';

const _documents = ['state', 'prd', 'tests', 'plan', 'questions', 'journal'];

/// Per-session conversation: a live transcript plus a chat composer.
///
/// The message list is rendered with `reverse: true` so the newest message sits
/// at the bottom and is visible the instant the screen opens — no manual scroll
/// math (which is unreliable for variable-height / Markdown bubbles in a lazily
/// built list). Scroll offset 0 == the bottom (newest).
class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({
    super.key,
    required this.store,
    required this.sessionId,
  });

  final SessionStore store;
  final String sessionId;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  int _lastMessageCount = 0;
  bool _atBottom = true;
  int _unreadWhileAway = 0;

  SessionStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    unawaited(_store.loadConversation(widget.sessionId));
    unawaited(_store.refreshSessions());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.position.pixels <= 80;
    if (atBottom != _atBottom) {
      setState(() {
        _atBottom = atBottom;
        if (atBottom) _unreadWhileAway = 0;
      });
    }
  }

  // Reverse list: the bottom (newest) is offset 0.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _jumpToBottom() {
    setState(() {
      _atBottom = true;
      _unreadWhileAway = 0;
    });
    _scrollToBottom();
  }

  Future<void> _send(String text, ComposerMode mode) async {
    // Sending implies wanting to see the result: snap to the bottom.
    _jumpToBottom();
    setState(() => _sending = true);
    final kind = mode == ComposerMode.answer
        ? 'answer'
        : mode == ComposerMode.confirmation
            ? 'confirmation'
            : 'chat';
    try {
      await _store.sendMessage(widget.sessionId, text: text, kind: kind);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('发送失败：$error')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openDocument(String name) async {
    final session = _store.session(widget.sessionId);
    if (session == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final document = await _store.readDocument(widget.sessionId, name);
      if (!mounted) return;
      Navigator.of(context).pop();
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => DocumentScreen(document: document),
      ));
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('无法打开文档：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final session = _store.session(widget.sessionId);
        final messages = _store.conversation(widget.sessionId);
        final awaiting = _store.awaitingReply(widget.sessionId);

        final grew = messages.length > _lastMessageCount;
        if (grew) {
          final delta = messages.length - _lastMessageCount;
          if (_atBottom) {
            _scrollToBottom();
          } else {
            _unreadWhileAway += delta;
          }
        }
        _lastMessageCount = messages.length;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            titleSpacing: 0,
            title: session == null ? const Text('会话') : _appBarTitle(session),
          ),
          body: Column(
            children: [
              if (session != null) _header(context, session),
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: _conversation(context, messages, awaiting),
                    ),
                    if (!_atBottom)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: _jumpButton(context),
                      ),
                  ],
                ),
              ),
              ChatComposer(onSend: _send, sending: _sending),
            ],
          ),
        );
      },
    );
  }

  Widget _jumpButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 3,
      color: Theme.of(context).cardColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _jumpToBottom,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: scheme.primary, size: 26),
              if (_unreadWhileAway > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      _unreadWhileAway > 99 ? '99+' : '$_unreadWhileAway',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarTitle(RuntimeSession session) {
    return Row(
      children: [
        AgentAvatar(agent: session.agent, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                AgentVisuals.agentLabel(session.agent.kind),
                style: TextStyle(
                  fontSize: 12,
                  color: AgentVisuals.agentColor(session.agent.kind),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, RuntimeSession session) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
            bottom: BorderSide(color: scheme.outlineVariant.withOpacity(0.6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(status: session.status),
              const SizedBox(width: 8),
              if ((session.phase ?? '').isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    session.phase!,
                    style: TextStyle(
                        color: scheme.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              const Spacer(),
              Text(session.feature,
                  style:
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _documents.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final name = _documents[index];
                return ActionChip(
                  avatar: const Icon(Icons.description_outlined, size: 16),
                  label: Text(name),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openDocument(name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversation(
      BuildContext context, List<ConversationMessage> messages, bool awaiting) {
    if (!_store.isConversationLoaded(widget.sessionId) && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (messages.isEmpty && !awaiting) {
      return ListView(
        children: const [
          EmptyState(
            icon: Icons.forum_outlined,
            title: '还没有消息',
            message: '在下面给这个会话发送一条消息，或等待 Agent 推进时自动同步。',
          ),
        ],
      );
    }
    // reverse: index 0 is the bottom. The typing indicator (if any) sits at the
    // very bottom (index 0); messages follow from newest upward.
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: messages.length + (awaiting ? 1 : 0),
      itemBuilder: (context, index) {
        if (awaiting && index == 0) return const TypingIndicator();
        final messageIndex =
            awaiting ? messages.length - index : messages.length - 1 - index;
        final message = messages[messageIndex];
        return MessageBubble(
          message: message,
          onRetry: message.failed
              ? () => _store.retryMessage(widget.sessionId, message.id)
              : null,
        );
      },
    );
  }
}
