import 'dart:convert';
import 'package:http/http.dart' as http;

class MicrolinkService {
  static const String _baseUrl = 'https://api.microlink.io';

  static Future<Map<String, dynamic>?> extractContent(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?url=$url'),
      ).timeout(const Duration(seconds: 30));

      print('Microlink API Status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        print('Microlink API Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];
        
        if (data != null) {
          return {
            'title': data['title'] ?? 'Untitled',
            'content': data['description'] ?? 'No content available',
            'description': data['description'] ?? '',
            'url': data['url'] ?? url,
            'siteName': data['publisher'] ?? Uri.parse(url).host,
            'image': data['image']?['url'],
          };
        }
      } else {
        print('Microlink API Error: ${response.statusCode} → ${response.body}');
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
