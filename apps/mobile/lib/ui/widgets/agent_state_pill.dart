import 'package:flutter/material.dart';

import '../../data/models/agent_state.dart';

/// Compact pill showing one agent's runtime state, e.g. "Agent · 处理中" or
/// "等待器 · 收信中", tinted by state (active=primary, error=red, offline=muted).
class AgentStatePill extends StatelessWidget {
  const AgentStatePill({super.key, required this.state});

  final AgentRuntimeState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = state.color(scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(state.icon, size: 13, color: c),
          const SizedBox(width: 5),
          Text(
            '${state.roleLabel} · ${state.stateLabel}',
            style:
                TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
