import 'package:flutter/material.dart';

/// Animated three-dot bubble shown while waiting for the agent to reply, like a
/// "typing…" indicator in a messaging app.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, this.label = 'Agent 处理中'});

  final String label;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label,
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => _dot(i, scheme.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(int index, Color color) {
    // Each dot pulses with a phase offset.
    final t = (_controller.value + index * 0.2) % 1.0;
    final scale = 0.6 + 0.4 * (1 - (2 * t - 1).abs());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
