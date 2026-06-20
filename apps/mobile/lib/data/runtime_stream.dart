import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/connection.dart';
import 'sse_parser.dart';

enum StreamStatus { connecting, live, reconnecting, disconnected }

/// A structured envelope from the runtime `/stream` endpoint. `kind` is either
/// `session` or `message`; `data` carries the matching JSON object.
class RuntimeEnvelope {
  const RuntimeEnvelope(this.kind, this.data);
  final String kind;
  final Map<String, dynamic> data;
}

/// Maintains a single authenticated SSE subscription to `/stream`, decodes
/// envelopes, and transparently reconnects.
///
/// Liveness is verified two ways so a half-open socket can't masquerade as
/// "live": every received byte (including the server's `: ping` keep-alive)
/// refreshes an activity timestamp, and a watchdog forces a reconnect if the
/// stream goes silent past [staleAfter]. Callers may also force an immediate
/// reconnect via [reconnectNow] when a REST request fails.
class RuntimeStream {
  RuntimeStream({
    required SandtableConnection connection,
    http.Client? client,
    this.reconnectDelay = const Duration(seconds: 2),
    this.staleAfter = const Duration(seconds: 35),
  })  : _connection = connection,
        _client = client ?? http.Client();

  final SandtableConnection _connection;
  final http.Client _client;
  final Duration reconnectDelay;
  final Duration staleAfter;

  final _envelopes = StreamController<RuntimeEnvelope>.broadcast();
  final ValueNotifier<StreamStatus> status =
      ValueNotifier<StreamStatus>(StreamStatus.connecting);

  StreamSubscription<SseFrame>? _subscription;
  Timer? _reconnectTimer;
  Timer? _watchdog;
  DateTime _lastActivity = DateTime.now();
  var _stopped = false;
  var _connectedOnce = false;

  Stream<RuntimeEnvelope> get envelopes => _envelopes.stream;

  Future<void> start() async {
    _stopped = false;
    _watchdog ??= Timer.periodic(const Duration(seconds: 10), (_) => _checkStale());
    await _connect();
  }

  /// Force an immediate reconnect (e.g. after a REST "connection refused").
  void reconnectNow() {
    if (_stopped) return;
    _scheduleReconnect(immediate: true);
  }

  void _checkStale() {
    if (_stopped) return;
    if (status.value == StreamStatus.live &&
        DateTime.now().difference(_lastActivity) > staleAfter) {
      // Socket looks alive but no bytes have arrived; treat as dead.
      _scheduleReconnect(immediate: true);
    }
  }

  Future<void> _connect() async {
    if (_stopped) return;
    status.value =
        _connectedOnce ? StreamStatus.reconnecting : StreamStatus.connecting;

    final uri = _connection.baseUrl
        .resolve('/stream')
        .replace(queryParameters: {'token': _connection.token});
    final request = http.Request('GET', uri)
      ..headers['accept'] = 'text/event-stream'
      ..headers['cache-control'] = 'no-cache';

    try {
      final response = await _client.send(request);
      if (response.statusCode >= 400) {
        _scheduleReconnect();
        return;
      }
      _connectedOnce = true;
      _lastActivity = DateTime.now();
      status.value = StreamStatus.live;
      // Tap the raw byte stream to track liveness (covers keep-alive comments).
      final tapped = response.stream.map((chunk) {
        _lastActivity = DateTime.now();
        return chunk;
      });
      _subscription = parseSseStream(tapped).listen(
        _onFrame,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onFrame(SseFrame frame) {
    _lastActivity = DateTime.now();
    if (frame.event.isEmpty) return;
    try {
      final decoded = jsonDecode(frame.data);
      if (decoded is! Map<String, dynamic>) return;
      _envelopes.add(RuntimeEnvelope(frame.event, decoded));
    } catch (_) {
      // Ignore malformed frames; the stream stays open.
    }
  }

  void _scheduleReconnect({bool immediate = false}) {
    if (_stopped) return;
    _subscription?.cancel();
    _subscription = null;
    status.value = StreamStatus.reconnecting;
    _reconnectTimer?.cancel();
    _reconnectTimer =
        Timer(immediate ? Duration.zero : reconnectDelay, () => unawaited(_connect()));
  }

  void dispose() {
    _stopped = true;
    _reconnectTimer?.cancel();
    _watchdog?.cancel();
    _subscription?.cancel();
    status.value = StreamStatus.disconnected;
    _envelopes.close();
    _client.close();
  }
}
