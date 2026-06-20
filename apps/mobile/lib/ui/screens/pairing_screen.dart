import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/models/connection.dart';
import '../../data/sandtable_api.dart';
import '../../data/server_history.dart';
import 'qr_scan_screen.dart';

/// Onboarding screen. Pair to a runtime server with a 4-digit code (printed by
/// `/sandtable-mobile-start`) or by scanning the pairing QR. One pairing grants
/// access to every session on that runtime.
class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key, required this.onConnect, this.initialMessage});

  final ValueChanged<SandtableConnection> onConnect;
  final String? initialMessage;

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final ServerHistory _history = ServerHistory();
  List<String> _savedServers = const [];
  String? _error;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _error = widget.initialMessage;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final servers = await _history.load();
    if (!mounted) return;
    setState(() {
      _savedServers = servers;
      if (_serverController.text.trim().isEmpty && servers.isNotEmpty) {
        _serverController.text = servers.first;
      }
    });
  }

  Future<void> _removeServer(String url) async {
    final servers = await _history.remove(url);
    if (!mounted) return;
    setState(() => _savedServers = servers);
  }

  @override
  void dispose() {
    _serverController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _connectByCode() async {
    final server = _serverController.text.trim();
    final code = _codeController.text.trim();
    if (server.isEmpty || code.length != 4) {
      setState(() => _error = '请输入 Server URL 和 4 位配对码。');
      return;
    }
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      final baseUrl = Uri.parse(server);
      final connection =
          await SandtableApi.pairByCode(baseUrl: baseUrl, code: code);
      await _history.remember(server);
      widget.onConnect(connection);
    } catch (error) {
      setState(() {
        _error = '$error';
        _connecting = false;
      });
    }
  }

  Future<void> _scanQr() async {
    final connection = await Navigator.of(context).push<SandtableConnection>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (connection != null) {
      await _history.remember(connection.baseUrl.toString());
      widget.onConnect(connection);
    }
  }

  Widget _savedServersSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _serverController.text.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近使用',
              style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final url in _savedServers)
                InputChip(
                  label: Text(url, style: const TextStyle(fontSize: 12.5)),
                  avatar: const Icon(Icons.dns_outlined, size: 16),
                  selected: url == selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _serverController.text = url),
                  onDeleted: () => _removeServer(url),
                  deleteIcon: const Icon(Icons.close, size: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 28),
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.grid_view_rounded,
                  color: scheme.primary, size: 30),
            ),
            const SizedBox(height: 20),
            Text('连接你的工作台',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              '配对一次，即可在手机上集中查看并管理所有 Codex、Cursor、Claude Code 或自定义 Agent 的会话。',
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
            ),
            const SizedBox(height: 28),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('手动配对',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'http://192.168.x.x:8765',
                      prefixIcon: Icon(Icons.dns_outlined),
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                  ),
                  if (_savedServers.isNotEmpty) _savedServersSection(context),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '4 位配对码',
                      hintText: '0000',
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26,
                        letterSpacing: 10,
                        fontWeight: FontWeight.w700),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _connecting ? null : _connectByCode,
                    icon: _connecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.link_rounded),
                    label: Text(_connecting ? '连接中…' : '连接'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: scheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('或',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                ),
                Expanded(child: Divider(color: scheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _scanQr,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('扫描配对二维码'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: scheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(color: scheme.error)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
