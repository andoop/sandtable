import 'package:flutter/material.dart';

import '../data/models/session.dart';

/// Maps agent kinds and session statuses to consistent colors, icons, and
/// labels. Centralizing this keeps every screen visually coherent and makes it
/// trivial to onboard a new agent kind.
class AgentVisuals {
  AgentVisuals._();

  static const Map<String, Color> _agentColors = {
    'codex': Color(0xff10a37f),
    'cursor': Color(0xff6938ef),
    'claude-code': Color(0xffd97706),
    'gemini': Color(0xff1a73e8),
    'custom': Color(0xff475467),
  };

  static Color agentColor(String kind) =>
      _agentColors[kind.toLowerCase()] ?? _agentColors['custom']!;

  static IconData agentIcon(String kind) {
    switch (kind.toLowerCase()) {
      case 'codex':
        return Icons.terminal_rounded;
      case 'cursor':
        return Icons.edit_note_rounded;
      case 'claude-code':
        return Icons.auto_awesome_rounded;
      case 'gemini':
        return Icons.diamond_outlined;
      default:
        return Icons.smart_toy_rounded;
    }
  }

  static String agentLabel(String kind) {
    switch (kind.toLowerCase()) {
      case 'codex':
        return 'Codex';
      case 'cursor':
        return 'Cursor';
      case 'claude-code':
        return 'Claude Code';
      case 'gemini':
        return 'Gemini';
      default:
        return kind.isEmpty ? 'Agent' : kind;
    }
  }

  static Color statusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.blocked:
        return const Color(0xffb42318);
      case SessionStatus.done:
        return const Color(0xff067647);
      case SessionStatus.stopped:
        return const Color(0xff667085);
      case SessionStatus.active:
        return const Color(0xff175cd3);
      case SessionStatus.idle:
        return const Color(0xff667085);
    }
  }

  static String statusLabel(SessionStatus status) {
    switch (status) {
      case SessionStatus.blocked:
        return '待处理';
      case SessionStatus.done:
        return '已完成';
      case SessionStatus.stopped:
        return '已停止';
      case SessionStatus.active:
        return '进行中';
      case SessionStatus.idle:
        return '空闲';
    }
  }
}
