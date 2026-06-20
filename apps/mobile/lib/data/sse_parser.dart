import 'dart:async';
import 'dart:convert';

/// A parsed Server-Sent Events frame: the event name and its data payload.
class SseFrame {
  const SseFrame(this.event, this.data);
  final String event;
  final String data;
}

/// Parses an SSE byte stream into discrete frames. Handles multi-line `data:`
/// fields, comments (`:` prefix), and CRLF line endings.
Stream<SseFrame> parseSseStream(Stream<List<int>> bytes) async* {
  var pending = '';
  var dataBuffer = StringBuffer();
  String? eventName;

  await for (final chunk in bytes.transform(utf8.decoder)) {
    pending += chunk;
    final parts = pending.split('\n');
    pending = parts.removeLast();

    for (final rawLine in parts) {
      final line = rawLine.endsWith('\r')
          ? rawLine.substring(0, rawLine.length - 1)
          : rawLine;
      if (line.isEmpty) {
        if (dataBuffer.isNotEmpty) {
          yield SseFrame(eventName ?? 'message', dataBuffer.toString());
          dataBuffer = StringBuffer();
          eventName = null;
        }
        continue;
      }
      if (line.startsWith(':')) continue;
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
        continue;
      }
      if (line.startsWith('data:')) {
        if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
        dataBuffer.write(line.substring(5).trimLeft());
      }
    }
  }

  if (dataBuffer.isNotEmpty) {
    yield SseFrame(eventName ?? 'message', dataBuffer.toString());
  }
}
