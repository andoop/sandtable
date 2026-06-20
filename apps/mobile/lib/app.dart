import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'state/connections_controller.dart';
import 'ui/screens/pairing_screen.dart';
import 'ui/screens/session_list_screen.dart';

/// Root widget. Owns the multi-server [ConnectionsController], restores all
/// saved servers on cold start, reconnects them on resume, and surfaces a
/// pairing screen when no servers are connected.
class SandtableApp extends StatefulWidget {
  const SandtableApp({super.key});

  @override
  State<SandtableApp> createState() => _SandtableAppState();
}

class _SandtableAppState extends State<SandtableApp>
    with WidgetsBindingObserver {
  final ConnectionsController _controller = ConnectionsController();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_controller.init());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.reconnectAll());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// Pair a new server (first connection or an additional one).
  void _addServer(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PairingScreen(
        onConnect: (connection) {
          Navigator.of(context).pop();
          unawaited(_controller.addConnection(connection));
        },
      ),
    ));
  }

  void _flushNotice() {
    final notice = _controller.consumeNotice();
    if (notice == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(notice)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sandtable',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          _flushNotice();
          if (_controller.isBooting) return const _SplashScreen();
          if (_controller.isEmpty) {
            return PairingScreen(
              onConnect: (connection) =>
                  unawaited(_controller.addConnection(connection)),
            );
          }
          return SessionListScreen(
            controller: _controller,
            onAddServer: () => _addServer(context),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.grid_view_rounded,
                  color: scheme.primary, size: 32),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
