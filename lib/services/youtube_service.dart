import 'dart:convert';
import 'package:http/http.dart' as http;

class JinaReaderService {
  static const String _apiKey = 'jina_ec0532bef19543128d7af3d5e53d813fCS94z0uxD4BNJC62N8GDeb0TL_QM';
  static const String _baseUrl = 'https://r.jina.ai';

  static Future<Map<String, dynamic>?> extractContent(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$url'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'X-Return-Format': 'json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'title': data['data']?['title'] ?? 'Untitled',
          'content': data['data']?['content'] ?? '',
          'description': data['data']?['description'] ?? '',
          'url': url,
          'siteName': data['data']?['siteName'] ?? '',
        };
      }
    } catch (e) {
      print('Error extracting content: $e');
    }
    return null;
  }

  static bool isValidUrl(String text) {
    final urlPattern = RegExp(
      r'^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text.trim());
  }
}