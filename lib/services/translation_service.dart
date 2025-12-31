import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _appId = '20251230002530232'; // Replace with your App ID
  static const String _appSecret = 'nhIRyfe2DVkz5Hdb0hk1'; // Replace with your App Secret
  static const String _baseUrl = 'https://fanyi-api.baidu.com/api/trans/vip/translate';

  // In-memory cache for translations
  final Map<String, String> _translationCache = {};

  // Chains requests to process them sequentially, respecting API rate limits.
  Completer<void> _requestChain = Completer()..complete();

  // Maps standard ISO language codes to Baidu-specific codes
  static final Map<String, String> _languageCodeMap = {
    'en': 'en',   // English
    'zh': 'zh',   // Chinese
    'fr': 'fra',  // French
    'de': 'de',   // German
    'ru': 'ru',   // Russian
    'es': 'spa',  // Spanish
    'ja': 'jp',   // Japanese
    'ko': 'kor',  // Korean
  };

  Future<String> translate(String query, String toLanguage) async {
    // If the target language is Chinese, no translation is needed.
    if (toLanguage == 'zh') {
      return query;
    }

    // Check cache first
    final cacheKey = '$toLanguage:$query';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    if (_appId == 'YOUR_BAIDU_APP_ID' || _appSecret == 'YOUR_BAIDU_APP_SECRET') {
      print('Baidu Translation API Error: App ID or App Secret is not set.');
      return '[请设置API密钥] $query';
    }

    // --- Start of change: Request Throttling ---
    // Create a new completer for the current request and chain it to the previous one.
    final currentRequestCompleter = Completer<void>();
    final previousRequestFuture = _requestChain.future;
    _requestChain = currentRequestCompleter;

    // Wait for the previous request to complete.
    await previousRequestFuture;

    // The entire translation logic is wrapped in a try/finally to ensure the queue progresses.
    try {
      // Re-check cache in case the translation was added while this request was waiting.
      if (_translationCache.containsKey(cacheKey)) {
        return _translationCache[cacheKey]!;
      }

      final lang = toLanguage.split('_').first.split('-').first.toLowerCase();
      final baiduLanguageCode = _languageCodeMap[lang] ?? lang;

      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      final sign = _generateSign(query, salt);
      final url = '$_baseUrl?q=${Uri.encodeComponent(query)}&from=auto&to=$baiduLanguageCode&appid=$_appId&salt=$salt&sign=$sign';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['trans_result'] != null && decoded['trans_result'].isNotEmpty) {
          final translatedText = decoded['trans_result'][0]['dst'];
          // Store result in cache
          _translationCache[cacheKey] = translatedText;
          return translatedText;
        } else if (decoded['error_code'] != null) {
          final errorCode = decoded['error_code'];
          final errorMsg = decoded['error_msg'];
          if (errorCode != '58001') {
            print('Baidu Translation API Error: $errorMsg (Code: $errorCode)');
          }
          // On failure, return the original query.
          return query;
        }
      }
      print('HTTP Error ${response.statusCode}');
      // On failure, return the original query.
      return query;
    } catch (e) {
      print('Failed to translate: $e');
      // On failure, return the original query.
      return query;
    } finally {
      // Add a 0.1-second delay to respect the API's rate limit.
      await Future.delayed(const Duration(milliseconds: 100));
      // Signal that this request is complete, allowing the next one in the chain to start.
      currentRequestCompleter.complete();
    }
    // --- End of change ---
  }

  String _generateSign(String query, String salt) {
    final str = '$_appId$query$salt$_appSecret';
    return md5.convert(utf8.encode(str)).toString();
  }
}
