import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/note.dart';

class LinkNoteScreen extends StatelessWidget {
  final Note note;

  const LinkNoteScreen({super.key, required this.note});

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
        actions: [
          if (note.linkUrl != null)
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Color(0xFF5E35B1)),
              onPressed: () => _launchUrl(note.linkUrl!),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Link', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (note.linkMetadata?['siteName'] != null)
                    Text(
                      note.linkMetadata!['siteName'],
                      style: TextStyle(fontSize: 14, color: const Color(0xFF5E35B1).withOpacity(0.7), fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    note.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note.content,
                    style: TextStyle(fontSize: 16, color: const Color(0xFF5E35B1).withOpacity(0.8), height: 1.6),
                  ),
                  if (note.linkUrl != null) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _launchUrl(note.linkUrl!),
                      child: Text(
                        note.linkUrl!,
                        style: const TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
