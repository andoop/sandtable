import 'package:flutter/material.dart';

/// Which agent the runtime state belongs to.
enum AgentRole { main, waiter }

/// Live runtime state of the main agent / waiting sub-agent, mirrored from the
/// server's `agent_state` broadcasts over `/stream`.
///
/// Main agent: idle / working / disconnected / error.
/// Waiting sub-agent: ready / waiting / processing / exited (+ error).
class AgentRuntimeState {
  const AgentRuntimeState({
    required this.role,
    required this.state,
    required this.at,
    this.detail,
  });

  final AgentRole role;
  final String state;
  final String? detail;
  final DateTime at;

  factory AgentRuntimeState.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String? ?? 'main').trim();
    return AgentRuntimeState(
      role: roleStr == 'waiter' ? AgentRole.waiter : AgentRole.main,
      state: (json['state'] as String? ?? '').trim(),
      detail: (json['detail'] as String?)?.trim(),
      at: DateTime.tryParse(json['at'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String get roleLabel => role == AgentRole.main ? 'Agent' : '等待器';

  String get stateLabel {
    switch (state) {
      case 'idle':
        return '空闲';
      case 'working':
        return '处理中';
      case 'disconnected':
        return '已断开';
      case 'error':
        return '出错';
      case 'ready':
        return '就绪';
      case 'waiting':
        return '收信中';
      case 'processing':
        return '处理中';
      case 'exited':
        return '已退出';
      default:
        return state.isEmpty ? '未知' : state;
    }
  }

  /// Active work/waiting — UI may emphasize these.
  bool get isActive =>
      state == 'working' || state == 'waiting' || state == 'processing';
  bool get isError => state == 'error';
  bool get isOffline => state == 'disconnected' || state == 'exited';

  Color color(ColorScheme scheme) {
    if (isError) return scheme.error;
    if (isOffline) return scheme.onSurfaceVariant;
    if (isActive) return scheme.primary;
    return scheme.tertiary; // idle / ready
  }

  IconData get icon {
    switch (state) {
      case 'working':
      case 'processing':
        return Icons.bolt_rounded;
      case 'waiting':
        return Icons.hourglass_top_rounded;
      case 'idle':
      case 'ready':
        return Icons.check_circle_outline_rounded;
      case 'error':
        return Icons.error_outline_rounded;
      case 'disconnected':
      case 'exited':
        return Icons.cloud_off_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
