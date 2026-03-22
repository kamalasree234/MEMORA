import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/note.dart';

class YouTubeNoteScreen extends StatelessWidget {
  final Note note;

  const YouTubeNoteScreen({super.key, required this.note});

  Future<void> _openYouTube() async {
    if (note.linkUrl != null) {
      final uri = Uri.parse(note.linkUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E35B1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          note.title,
          style: const TextStyle(color: Color(0xFF5E35B1), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.linkMetadata?['thumbnailUrl'] != null)
              GestureDetector(
                onTap: _openYouTube,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB39DDB).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          note.linkMetadata!['thumbnailUrl'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB39DDB).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('YouTube', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1)),
                  ),
                  const SizedBox(height: 8),
                  if (note.linkMetadata?['channelTitle'] != null)
                    Text(
                      'by ${note.linkMetadata!['channelTitle']}',
                      style: TextStyle(fontSize: 16, color: const Color(0xFF5E35B1).withOpacity(0.7), fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    note.content,
                    style: TextStyle(fontSize: 16, color: const Color(0xFF5E35B1).withOpacity(0.8), height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openYouTube,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Watch on YouTube'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB39DDB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
