import 'package:shared_preferences/shared_preferences.dart';

/// Persists recently used server URLs so the developer can pick one instead of
/// retyping the LAN address each time. Most-recent first, deduped, capped.
class ServerHistory {
  static const String _key = 'sandtable.server_urls';
  static const int _maxEntries = 8;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  /// Record [url] as the most recently used server. No-op for blank input.
  Future<List<String>> remember(String url) async {
    final value = url.trim();
    if (value.isEmpty) return load();
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    current
      ..removeWhere((entry) => entry == value)
      ..insert(0, value);
    final trimmed = current.take(_maxEntries).toList();
    await prefs.setStringList(_key, trimmed);
    return trimmed;
  }

  Future<List<String>> remove(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    current.removeWhere((entry) => entry == url);
    await prefs.setStringList(_key, current);
    return current;
  }
}
