import 'dart:convert';
import 'package:http/http.dart' as http;

class TranscriptService {
  static const String apiUrl = 'http://localhost:8000'; // Change to your deployed URL
  
  static Future<String?> fetchTranscript(String youtubeUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/transcript'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': youtubeUrl}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transcript'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
