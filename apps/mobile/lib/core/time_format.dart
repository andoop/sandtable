/// Lightweight relative-time formatting (Chinese), dependency-free.
String timeAgo(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inSeconds < 45) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
  if (diff.inHours < 24) return '${diff.inHours} 小时前';
  if (diff.inDays < 7) return '${diff.inDays} 天前';
  return '${time.year}-${_two(time.month)}-${_two(time.day)}';
}

/// Clock time for chat bubbles, e.g. `09:05`.
String clockTime(DateTime time) => '${_two(time.hour)}:${_two(time.minute)}';

String _two(int value) => value.toString().padLeft(2, '0');
