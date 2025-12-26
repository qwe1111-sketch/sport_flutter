import 'dart:developer';

class UrlFormatter {
  static const String _baseUrl = 'http://47.253.229.197:3030';

  static String format(String? relativePath) {
    log('[UrlFormatter] Formatting path: "$relativePath"');
    if (relativePath == null || relativePath.isEmpty) {
      log('[UrlFormatter] Path is null or empty, returning empty string.');
      return '';
    }
    // FIX: Check for both 'http' and 'https' to correctly identify absolute URLs.
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      log('[UrlFormatter] Path is already absolute: "$relativePath"');
      return relativePath;
    }
    final formattedUrl = _baseUrl + (relativePath.startsWith('/') ? relativePath : '/' + relativePath);
    log('[UrlFormatter] Formatted URL: "$formattedUrl"');
    return formattedUrl;
  }
}
