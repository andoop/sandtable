import 'package:flutter/material.dart';

import '../../core/agent_visuals.dart';
import '../../data/models/agent.dart';

/// Circular avatar branded by agent kind (color + icon).
class AgentAvatar extends StatelessWidget {
  const AgentAvatar({super.key, required this.agent, this.size = 44});

  final AgentIdentity agent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AgentVisuals.agentColor(agent.kind);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        AgentVisuals.agentIcon(agent.kind),
        color: color,
        size: size * 0.5,
      ),
    );
  }
}
