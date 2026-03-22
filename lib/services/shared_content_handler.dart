import 'dart:async';
import 'package:share_handler/share_handler.dart';
import 'package:flutter/material.dart';
import 'jina_ai_service.dart';
import '../models/note.dart';

class SharedContentHandler {
  static StreamSubscription? _streamSubscription;

  static void initialize(BuildContext context, Function(Note) onNoteCreated) async {
    final handler = ShareHandlerPlatform.instance;
    
    // Handle cold start (app launched from share)
    final media = await handler.getInitialSharedMedia();
    if (media != null && media.content != null && context.mounted) {
      _processSharedContent(context, media.content!, onNoteCreated);
    }
    
    // Handle hot start (app already running)
    _streamSubscription = handler.sharedMediaStream.listen((media) {
      if (media.content != null && context.mounted) {
        _processSharedContent(context, media.content!, onNoteCreated);
      }
    });
  }

  static void dispose() {
    _streamSubscription?.cancel();
  }

  static Future<void> _processSharedContent(
    BuildContext context,
    String content,
    Function(Note) onNoteCreated,
  ) async {
    if (!_isValidUrl(content)) return;

    _showProcessingDialog(context);

    try {
      final result = await JinaAIService.processUrl(content);
      
      final note = Note(
        id: '',
        title: result['title'],
        content: result['summary'],
        richContent: result['content'],
        tags: List<String>.from(result['tags']),
        category: 'Shared',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      onNoteCreated(note);
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Link saved as note!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static bool _isValidUrl(String text) {
    return Uri.tryParse(text)?.hasScheme ?? false;
  }

  static void _showProcessingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB39DDB)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Processing shared link...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Extracting content and creating note',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
