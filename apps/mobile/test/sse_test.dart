import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sandtable_mobile_review/data/sse_parser.dart';

void main() {
  test('parses SSE frames from a chunked stream', () async {
    final controller = StreamController<List<int>>();
    final framesFuture = parseSseStream(controller.stream).toList();
    controller.add(utf8.encode('event: message\n'));
    controller.add(utf8.encode(
        'data: {"kind":"message","message":{"id":"m1","kind":"chat"}}\n\n'));
    await controller.close();
    final frames = await framesFuture;

    expect(frames, hasLength(1));
    expect(frames.first.event, 'message');
    expect(frames.first.data, contains('"kind":"chat"'));
  });

  test('ignores comment/keepalive lines', () async {
    final controller = StreamController<List<int>>();
    final framesFuture = parseSseStream(controller.stream).toList();
    controller.add(utf8.encode(': ping\n\n'));
    controller.add(utf8.encode('event: session\ndata: {"kind":"session"}\n\n'));
    await controller.close();
    final frames = await framesFuture;

    expect(frames, hasLength(1));
    expect(frames.first.event, 'session');
  });
}
