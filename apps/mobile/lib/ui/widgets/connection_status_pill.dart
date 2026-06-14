import 'package:flutter/material.dart';

import '../../data/runtime_stream.dart';

/// Live connection indicator driven by the `/stream` status.
class ConnectionStatusPill extends StatelessWidget {
  const ConnectionStatusPill({super.key, required this.status});

  final StreamStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    switch (status) {
      case StreamStatus.live:
        color = const Color(0xff067647);
        label = '实时';
        break;
      case StreamStatus.connecting:
        color = const Color(0xffb54708);
        label = '连接中';
        break;
      case StreamStatus.reconnecting:
        color = const Color(0xffb54708);
        label = '重连中';
        break;
      case StreamStatus.disconnected:
        color = const Color(0xff667085);
        label = '已断开';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
