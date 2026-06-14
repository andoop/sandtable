# Sandtable Mobile Companion

A Flutter app to connect to a Sandtable runtime server and manage many agent
sessions (Codex / Cursor / Claude Code / custom) at once — browse session
status, open a session to chat in real time, and read feature documents.

## Architecture

The code is split into clear layers so each piece is small, decoupled, and easy
to extend. Dependencies point downward only (ui → state → data → core).

```
lib/
  main.dart                 App entry point.
  app.dart                  Root widget: theme + top-level routing, owns SessionStore.

  core/                     Cross-cutting, framework-light helpers.
    theme.dart              Light/dark themes + shared SurfaceCard.
    agent_visuals.dart      Color / icon / label per agent kind & session status.
    time_format.dart        Relative + clock time formatting.

  data/                     Pure data + IO. No widgets.
    models/                 Immutable models with fromJson (agent, session,
                            message, document, connection).
    sandtable_api.dart      Typed REST client (pairing, sessions, messages, docs).
    runtime_stream.dart     Single /stream SSE subscription with auto-reconnect,
                            decoded into typed RuntimeEnvelope objects.
    sse_parser.dart         Byte-stream → SSE frame parser.

  state/
    connections_controller.dart  ChangeNotifier managing ALL connected servers;
                            exposes an aggregated session list and add/remove.
    session_store.dart      ChangeNotifier for ONE server: sessions, conversations,
                            live stream, optimistic send, delete.

  ui/
    screens/                One screen per route (pairing, list, detail, servers, docs).
    widgets/                Reusable, presentational widgets.
```

### Data flow

1. `PairingScreen` produces a `SandtableConnection` (4-digit code or QR scan).
2. `ConnectionsController` persists it (via `ConnectionsRepository`) and creates a
   `SessionStore` per server; each opens its own `/stream` and loads sessions.
3. The home screen shows an **aggregated** list across all servers; each
   `SessionStore` applies `session` / `message` / `session_removed` envelopes from
   its stream. Multiple repos/servers are managed side by side.
4. Sending a message inserts an optimistic bubble immediately; the server echoes
   the authoritative copy back over the stream, which reconciles it.

### Adding things

- New agent kind: add a color/icon/label in `core/agent_visuals.dart`.
- New screen: add under `ui/screens/`, read state from the injected `SessionStore`
  / `ConnectionsController`.
- New server capability: add a method to `data/sandtable_api.dart` (REST) or a
  new envelope kind handled in `state/session_store.dart` (stream).
- Multiple servers/repos are first-class: connect to several at once and manage
  them from the Servers screen; sessions are shown in one aggregated list.

## Develop

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Pair with a runtime server started via `/sandtable-mobile-start` (it prints a
LAN URL + 4-digit code), or scan the `sandtable://pair?...` QR from `GET /pairing`.
