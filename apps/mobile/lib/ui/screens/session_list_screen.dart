import 'package:flutter/material.dart';

import '../../data/runtime_stream.dart';
import '../../state/connections_controller.dart';
import '../widgets/connection_status_pill.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_tile.dart';
import 'servers_screen.dart';
import 'session_detail_screen.dart';

/// Home / management screen: every session across every connected server, with
/// live status, swipe-to-delete, and entries to add or manage servers.
class SessionListScreen extends StatelessWidget {
  const SessionListScreen({
    super.key,
    required this.controller,
    required this.onAddServer,
  });

  final ConnectionsController controller;
  final VoidCallback onAddServer;

  void _openServers(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          ServersScreen(controller: controller, onAddServer: onAddServer),
    ));
  }

  Future<bool> _confirmDelete(BuildContext context, AggregatedSession item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除会话？'),
        content: Text(
            '将从列表移除「${item.session.title}」并清空其对话记录。如果该 Agent 之后继续推进，会话可能会重新出现。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final sessions = controller.sessions;
        final multiServer = controller.connections.length > 1;
        return Scaffold(
          appBar: AppBar(
            title: const Text('会话'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Center(
                    child: ConnectionStatusPill(
                        status: controller.aggregateStatus)),
              ),
              IconButton(
                tooltip: '添加服务器',
                icon: const Icon(Icons.add_rounded),
                onPressed: onAddServer,
              ),
              IconButton(
                tooltip: '服务器',
                icon: const Icon(Icons.dns_outlined),
                onPressed: () => _openServers(context),
              ),
            ],
          ),
          body: Column(
            children: [
              _connectionBanner(context, controller.aggregateStatus),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshAll,
                  child: _body(context, sessions, multiServer),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _connectionBanner(BuildContext context, StreamStatus status) {
    if (status == StreamStatus.live) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final reconnecting = status == StreamStatus.connecting ||
        status == StreamStatus.reconnecting;
    return Material(
      color: scheme.errorContainer.withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: reconnecting
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Icon(Icons.cloud_off_rounded, size: 16, color: scheme.error),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reconnecting ? '正在重新连接服务器…' : '部分服务器已断开',
                style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
              ),
            ),
            TextButton(
                onPressed: controller.reconnectAll, child: const Text('重连')),
          ],
        ),
      ),
    );
  }

  Widget _body(
      BuildContext context, List<AggregatedSession> sessions, bool multiServer) {
    if (sessions.isEmpty) {
      return ListView(children: const [
        EmptyState(
          icon: Icons.inbox_rounded,
          title: '还没有会话',
          message: '在电脑端某个 Agent 上运行 /sandtable-mobile-start，会话会自动出现在这里。',
        ),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: sessions.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _summaryHeader(context, sessions.length);
        }
        final item = sessions[index - 1];
        return Dismissible(
          key: ValueKey('${item.connection.id}/${item.session.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context, item),
          onDismissed: (_) => item.connection.store.deleteSession(item.session.id),
          background: _deleteBackground(context),
          child: SessionTile(
            session: item.session,
            serverLabel: multiServer ? item.connection.label : null,
            unread: item.connection.store.isUnread(item.session.id),
            onTap: () {
              item.connection.store.markRead(item.session.id);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SessionDetailScreen(
                    store: item.connection.store,
                    sessionId: item.session.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _deleteBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: scheme.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: scheme.error),
          const SizedBox(width: 6),
          Text('删除',
              style:
                  TextStyle(color: scheme.error, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _summaryHeader(BuildContext context, int total) {
    final scheme = Theme.of(context).colorScheme;
    final servers = controller.connections.length;
    final unread = controller.unreadSessionCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              '$servers 个服务器 · $total 个会话 · ${controller.activeSessionCount} 个进行中',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$unread 条未读',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
          const Spacer(),
          Text('左滑删除',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}
