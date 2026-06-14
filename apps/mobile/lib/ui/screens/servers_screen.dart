import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../state/connections_controller.dart';
import '../widgets/connection_status_pill.dart';

/// Manage connected servers (repos / runtime instances): see status, add a new
/// one, or remove an existing one.
class ServersScreen extends StatelessWidget {
  const ServersScreen({
    super.key,
    required this.controller,
    required this.onAddServer,
  });

  final ConnectionsController controller;
  final VoidCallback onAddServer;

  Future<void> _confirmRemove(
      BuildContext context, ManagedConnection managed) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除服务器？'),
        content: Text('将断开并清除「${managed.label}」的本地连接，需要重新配对才能再次连接。电脑端不受影响。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (ok == true) controller.removeConnection(managed.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器'),
        actions: [
          IconButton(
            tooltip: '添加服务器',
            icon: const Icon(Icons.add_rounded),
            onPressed: onAddServer,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final connections = controller.connections;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              for (final managed in connections) ...[
                _ServerCard(
                  managed: managed,
                  onRemove: () => _confirmRemove(context, managed),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onAddServer,
                icon: const Icon(Icons.add_rounded),
                label: const Text('添加服务器'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  const _ServerCard({required this.managed, required this.onRemove});

  final ManagedConnection managed;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sessionCount = managed.store.sessions.length;
    return SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.dns_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(managed.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: managed.store.streamStatus,
                      builder: (context, status, _) =>
                          ConnectionStatusPill(status: status),
                    ),
                    const SizedBox(width: 8),
                    Text('$sessionCount 个会话',
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: 12.5)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '移除',
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
