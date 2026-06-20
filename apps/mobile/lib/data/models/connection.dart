/// An authenticated link to a Sandtable runtime server. One connection grants
/// access to every session on that runtime (device-level pairing).
class SandtableConnection {
  const SandtableConnection({
    required this.baseUrl,
    required this.token,
  });

  final Uri baseUrl;
  final String token;

  String get label => '${baseUrl.host}:${baseUrl.port}';

  /// Parse a scanned QR payload shaped as `sandtable://pair?url=..&token=..`.
  factory SandtableConnection.fromPairingPayload(String raw) {
    final uri = Uri.parse(raw.trim());
    if (uri.scheme != 'sandtable' || uri.host != 'pair') {
      throw const FormatException('不是有效的 Sandtable 配对二维码');
    }
    final url = uri.queryParameters['url'];
    final token = uri.queryParameters['token'];
    if (url == null || token == null) {
      throw const FormatException('配对二维码缺少 url 或 token');
    }
    return SandtableConnection(baseUrl: Uri.parse(url), token: token);
  }
}
