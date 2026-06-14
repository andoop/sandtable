import 'package:flutter/material.dart';

import '../../core/agent_visuals.dart';
import '../../core/theme.dart';
import '../../core/time_format.dart';
import '../../data/models/session.dart';
import 'agent_avatar.dart';
import 'status_badge.dart';

/// Rich list row summarizing one session: agent, title, phase, latest activity.
class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.session,
    required this.onTap,
    this.serverLabel,
  });

  final RuntimeSession session;
  final VoidCallback onTap;

  /// Optional server/repo label, shown when managing more than one server.
  final String? serverLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final phase = (session.phase ?? '').trim();
    final summary = (session.summary ?? '').trim();
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AgentAvatar(agent: session.agent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          AgentVisuals.agentLabel(session.agent.kind),
                          style: TextStyle(
                            color: AgentVisuals.agentColor(session.agent.kind),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (phase.isNotEmpty) ...[
                          Text(' · ',
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                          Flexible(
                            child: Text(
                              phase,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: session.status),
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: scheme.onSurfaceVariant, fontSize: 13.5, height: 1.35),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 13, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                timeAgo(session.lastActivityAt),
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
              const Spacer(),
              if (serverLabel != null && serverLabel!.isNotEmpty)
                _footerChip(scheme, Icons.dns_outlined, serverLabel!)
              else if (session.workspace.isNotEmpty)
                _footerChip(
                    scheme, Icons.folder_outlined, _workspaceName(session.workspace)),
            ],
          ),
        ],
      ),
    );
  }

  String _workspaceName(String workspace) {
    final parts = workspace.split('/')..removeWhere((p) => p.isEmpty);
    return parts.isEmpty ? workspace : parts.last;
  }

  Widget _footerChip(ColorScheme scheme, IconData icon, String label) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
