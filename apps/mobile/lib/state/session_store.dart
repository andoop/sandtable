import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/connections_repository.dart';
import '../data/models/connection.dart';
import '../data/models/document.dart';
import '../data/models/message.dart';
import '../data/models/session.dart';
import '../data/runtime_stream.dart';
import '../data/sandtable_api.dart';

/// Single source of truth for one connected server. Owns the REST client and
/// the live `/stream` subscription, keeps an in-memory cache of sessions and
/// their conversations, and notifies listeners on every change.
///
/// UI widgets observe this with `AnimatedBuilder(animation: store)`. All network
/// detail lives in [SandtableApi] / [RuntimeStream] so screens stay declarative.
class SessionStore extends ChangeNotifier {
  SessionStore({
    required this.id,
    required this.connection,
    required SessionCache cache,
    required ReadMarksCache readMarks,
  })  : api = SandtableApi(connection),
        _cache = cache,
        _readMarks = readMarks,
        _stream = RuntimeStream(connection: connection);

  /// Stable id of the owning connection (used for per-server caching/routing).
  final String id;
  final SandtableConnection connection;
  final SandtableApi api;
  final SessionCache _cache;
  final ReadMarksCache _readMarks;
  final RuntimeStream _stream;

  /// How long to keep the "Agent is working" indicator before giving up.
  static const Duration _awaitReplyTimeout = Duration(seconds: 120);

  StreamSubscription<RuntimeEnvelope>? _streamSub;

  final Map<String, RuntimeSession> _sessions = {};
  final Map<String, List<ConversationMessage>> _conversations = {};
  final Set<String> _conversationLoaded = {};
  final Map<String, bool> _awaitingReply = {};
  final Map<String, Timer> _awaitTimers = {};

  /// sessionId → the session activity time the user has already seen. A session
  /// is "unread" when its [RuntimeSession.lastActivityAt] is newer than this.
  final Map<String, DateTime> _readMarksData = {};
  bool _seedReadOnNextList = false;

  bool _loadingSessions = false;
  String? _sessionsError;
  bool _unauthorized = false;
  int _localSeq = 0;

  ValueListenable<StreamStatus> get streamStatus => _stream.status;
  bool get loadingSessions => _loadingSessions;
  String? get sessionsError => _sessionsError;
  bool get unauthorized => _unauthorized;

  /// Sessions sorted by most-recent activity (active/blocked float to the top).
  List<RuntimeSession> get sessions {
    final list = _sessions.values.toList();
    list.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    return list;
  }

  RuntimeSession? session(String id) => _sessions[id];

  List<ConversationMessage> conversation(String sessionId) =>
      List.unmodifiable(_conversations[sessionId] ?? const []);

  bool isConversationLoaded(String sessionId) =>
      _conversationLoaded.contains(sessionId);

  /// True while we are waiting for the agent to respond to a sent chat message.
  bool awaitingReply(String sessionId) => _awaitingReply[sessionId] ?? false;

  /// Whether [sessionId] has activity the user has not seen yet. A session with
  /// no read mark counts as unread (it's new to the user) unless it predates
  /// read tracking, in which case it was seeded as read on first list load.
  bool isUnread(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) return false;
    final mark = _readMarksData[sessionId];
    if (mark == null) return true;
    return session.lastActivityAt.isAfter(mark);
  }

  /// Total number of sessions with unseen activity, for an aggregate badge.
  int get unreadCount =>
      _sessions.keys.where(isUnread).length;

  /// Mark [sessionId] as read up to its current activity. Idempotent: only
  /// notifies/persists when the stored mark actually advances.
  void markRead(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) return;
    final existing = _readMarksData[sessionId];
    if (existing != null && !session.lastActivityAt.isAfter(existing)) return;
    _readMarksData[sessionId] = session.lastActivityAt;
    unawaited(_readMarks.save(_readMarksData));
    notifyListeners();
  }

  Future<void> init() async {
    final cached = await _cache.load();
    if (cached.isNotEmpty && _sessions.isEmpty) {
      _sessions.addEntries(cached.map((s) => MapEntry(s.id, s)));
      notifyListeners();
    }
    final marks = await _readMarks.load();
    _readMarksData.addAll(marks);
    // First run on this server: don't blast every pre-existing session as
    // unread — seed them as read once the first authoritative list arrives.
    _seedReadOnNextList = marks.isEmpty;
    _stream.status.addListener(notifyListeners);
    _streamSub = _stream.envelopes.listen(_onEnvelope);
    await _stream.start();
    await refreshSessions();
  }

  Future<void> reconnect() async {
    _stream.reconnectNow();
    await refreshSessions();
  }

  Future<void> refreshSessions() async {
    _loadingSessions = true;
    _sessionsError = null;
    notifyListeners();
    try {
      final sessions = await api.listSessions();
      final ids = sessions.map((s) => s.id).toSet();
      _sessions
        ..clear()
        ..addEntries(sessions.map((s) => MapEntry(s.id, s)));
      // Drop conversations/indicators for sessions that no longer exist.
      _conversations.removeWhere((id, _) => !ids.contains(id));
      _awaitingReply.removeWhere((id, _) => !ids.contains(id));
      _pruneReadMarks(ids);
      if (_seedReadOnNextList) {
        _seedReadOnNextList = false;
        for (final s in sessions) {
          _readMarksData[s.id] = s.lastActivityAt;
        }
        unawaited(_readMarks.save(_readMarksData));
      }
      unawaited(_cache.save(sessions));
    } on SandtableAuthException {
      _flagUnauthorized();
    } catch (error) {
      _sessionsError = '$error';
      _stream.reconnectNow();
    } finally {
      _loadingSessions = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(String sessionId, {bool refresh = false}) async {
    if (_conversationLoaded.contains(sessionId) && !refresh) return;
    try {
      final messages = await api.readConversation(sessionId);
      // Preserve any in-flight optimistic messages not yet echoed back.
      final pending =
          (_conversations[sessionId] ?? const []).where((m) => m.isLocal).toList();
      _conversations[sessionId] = [...messages, ...pending];
      _conversationLoaded.add(sessionId);
      notifyListeners();
    } on SandtableAuthException {
      _flagUnauthorized();
    } catch (_) {
      _stream.reconnectNow();
    }
  }

  Future<SandtableDocument> readDocument(String sessionId, String name) async {
    try {
      return await api.readDocument(sessionId, name);
    } on SandtableAuthException {
      _flagUnauthorized();
      rethrow;
    } catch (_) {
      _stream.reconnectNow();
      rethrow;
    }
  }

  /// Send a message with an immediate optimistic bubble. The bubble shows a
  /// "sending" state until the server echoes the authoritative copy back over
  /// the stream (which replaces it), or a "failed" state with retry on error.
  Future<void> sendMessage(
    String sessionId, {
    required String text,
    String kind = 'chat',
    String target = 'conversation',
  }) async {
    final feature = _sessions[sessionId]?.feature ?? '';
    final localId = 'local_${DateTime.now().microsecondsSinceEpoch}_${_localSeq++}';
    final optimistic = ConversationMessage.local(
      id: localId,
      sessionId: sessionId,
      feature: feature,
      text: text,
      kind: _composerKind(kind),
    );
    final list = _conversations.putIfAbsent(sessionId, () => []);
    list.add(optimistic);
    if (kind == 'chat') _beginAwaitingReply(sessionId);
    notifyListeners();

    try {
      await api.sendMessage(sessionId, text: text, kind: kind, target: target);
      _updateLocal(sessionId, localId, (m) => m.copyWith(pending: false));
    } on SandtableAuthException {
      _flagUnauthorized();
      _updateLocal(sessionId, localId, (m) => m.copyWith(pending: false, failed: true));
      _clearAwaitingReply(sessionId);
    } catch (_) {
      _updateLocal(sessionId, localId, (m) => m.copyWith(pending: false, failed: true));
      _clearAwaitingReply(sessionId);
      _stream.reconnectNow();
    }
  }

  /// Retry a previously failed optimistic message.
  Future<void> retryMessage(String sessionId, String localId) async {
    final list = _conversations[sessionId];
    if (list == null) return;
    final index = list.indexWhere((m) => m.id == localId);
    if (index < 0) return;
    final message = list[index];
    list.removeAt(index);
    notifyListeners();
    await sendMessage(sessionId, text: message.text, kind: _kindToComposer(message.kind));
  }

  Future<void> deleteSession(String sessionId) async {
    _removeSessionLocal(sessionId);
    notifyListeners();
    try {
      await api.deleteSession(sessionId);
    } on SandtableAuthException {
      _flagUnauthorized();
    } catch (_) {
      // Failed to delete on the server — resync so the list stays truthful.
      await refreshSessions();
    }
  }

  // --- live stream handling ----------------------------------------------

  void _onEnvelope(RuntimeEnvelope envelope) {
    switch (envelope.kind) {
      case 'session':
        _applySession(envelope.data['session']);
        break;
      case 'session_removed':
        final id = envelope.data['sessionId'];
        if (id is String) {
          _removeSessionLocal(id);
          notifyListeners();
        }
        break;
      case 'message':
        _applyMessage(envelope.data['message']);
        break;
    }
  }

  void _applySession(dynamic raw) {
    if (raw is! Map<String, dynamic>) return;
    final session = RuntimeSession.fromJson(raw);
    _sessions[session.id] = session;
    notifyListeners();
  }

  void _applyMessage(dynamic raw) {
    if (raw is! Map<String, dynamic>) return;
    final message = ConversationMessage.fromJson(raw);
    final list = _conversations.putIfAbsent(message.sessionId, () => []);
    if (list.any((m) => m.id == message.id)) return; // already have it

    if (message.isFromMobile) {
      // Reconcile with the optimistic placeholder of the same text.
      final localIndex = list.indexWhere(
          (m) => m.isLocal && m.isFromMobile && m.text == message.text);
      if (localIndex >= 0) list.removeAt(localIndex);
    } else {
      // Any agent/system message means the agent responded.
      _clearAwaitingReply(message.sessionId);
    }

    list.add(message);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  // --- helpers ------------------------------------------------------------

  void _updateLocal(
    String sessionId,
    String localId,
    ConversationMessage Function(ConversationMessage) update,
  ) {
    final list = _conversations[sessionId];
    if (list == null) return;
    final index = list.indexWhere((m) => m.id == localId);
    if (index < 0) return;
    list[index] = update(list[index]);
    notifyListeners();
  }

  void _removeSessionLocal(String sessionId) {
    _sessions.remove(sessionId);
    _conversations.remove(sessionId);
    _conversationLoaded.remove(sessionId);
    if (_readMarksData.remove(sessionId) != null) {
      unawaited(_readMarks.save(_readMarksData));
    }
    _clearAwaitingReply(sessionId);
  }

  /// Forget read marks for sessions the server no longer reports.
  void _pruneReadMarks(Set<String> liveIds) {
    final before = _readMarksData.length;
    _readMarksData.removeWhere((id, _) => !liveIds.contains(id));
    if (_readMarksData.length != before) {
      unawaited(_readMarks.save(_readMarksData));
    }
  }

  void _beginAwaitingReply(String sessionId) {
    _awaitingReply[sessionId] = true;
    _awaitTimers[sessionId]?.cancel();
    _awaitTimers[sessionId] = Timer(_awaitReplyTimeout, () {
      _awaitingReply[sessionId] = false;
      _awaitTimers.remove(sessionId);
      notifyListeners();
    });
  }

  void _clearAwaitingReply(String sessionId) {
    if (_awaitingReply.remove(sessionId) != null) {
      _awaitTimers.remove(sessionId)?.cancel();
    }
  }

  MessageKind _composerKind(String kind) {
    switch (kind) {
      case 'answer':
        return MessageKind.answer;
      case 'confirmation':
        return MessageKind.confirmation;
      default:
        return MessageKind.chat;
    }
  }

  String _kindToComposer(MessageKind kind) {
    switch (kind) {
      case MessageKind.answer:
        return 'answer';
      case MessageKind.confirmation:
        return 'confirmation';
      default:
        return 'chat';
    }
  }

  void _flagUnauthorized() {
    if (_unauthorized) return;
    _unauthorized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _awaitTimers.values) {
      timer.cancel();
    }
    _awaitTimers.clear();
    _stream.status.removeListener(notifyListeners);
    _streamSub?.cancel();
    _stream.dispose();
    api.dispose();
    super.dispose();
  }
}
