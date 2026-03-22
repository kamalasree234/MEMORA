import 'dart:convert';
import 'package:http/http.dart' as http;

class MicrolinkService {
  static const String _baseUrl = 'https://api.microlink.io';

  static Future<Map<String, dynamic>?> extractContent(String url) async {
    try {
      print('🔍 Extracting content from: $url');
      
      final response = await http.get(
        Uri.parse('$_baseUrl?url=${Uri.encodeComponent(url)}'),
      ).timeout(const Duration(seconds: 30));

      print('📡 Microlink API Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Response received: ${jsonData.toString().substring(0, jsonData.toString().length > 100 ? 100 : jsonData.toString().length)}');
        
        final data = jsonData['data'];
        
        if (data != null) {
          final result = {
            'title': data['title'] ?? 'Untitled',
            'content': data['description'] ?? 'No content available',
            'description': data['description'] ?? '',
            'url': data['url'] ?? url,
            'siteName': data['publisher'] ?? Uri.parse(url).host,
            'image': data['image']?['url'],
          };
          print('✅ Extracted: ${result['title']}');
          return result;
        } else {
          print('❌ No data in response');
        }
      } else {
        print('❌ Microlink API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ Error extracting content: $e');
      print('Stack trace: $stackTrace');
    }
    return null;
  }

  static bool isValidUrl(String text) {
    final urlPattern = RegExp(
      r'^https?://[\w\-]+(\.\w+)+[/#?]?.*$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text.trim());
  }
}
