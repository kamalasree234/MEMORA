import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../screens/rich_note_editor_screen.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _current;
  late AnimationController _progressController;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    _startProgress();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();
    _markRead();
  }

  Future<void> _markRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final story = widget.stories[_current];
    if (story['isRead'] == true) return;
    final id = story['id'] as String;
    final type = story['type'] as String;
    await _firestoreService.markAsRead(uid, id, type);
    await NotificationService.cancelReminders(id);
    story['isRead'] = true;
  }

  void _next() {
    if (_current < widget.stories.length - 1) {
      setState(() => _current++);
      _startProgress();
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() => _current--);
      _startProgress();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_current];
    final title = story['title'] as String? ?? '';
    final content = story['content'] as String? ?? '';
    final type = story['type'] as String;
    final tags = story['tags'] is List ? List<String>.from(story['tags']) : <String>[];
    final createdAt = story['createdAt'] is Timestamp
        ? (story['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final readTime = (content.split(' ').length / 200).ceil().clamp(1, 99);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _prev();
          } else {
            _next();
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -300) _next();
            if (details.primaryVelocity! > 300) _prev();
          }
        },
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D1B69), Color(0xFF5E35B1), Color(0xFFB39DDB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: List.generate(widget.stories.length, (i) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: i < _current
                                  ? Container(height: 3, color: Colors.white)
                                  : i == _current
                                      ? AnimatedBuilder(
                                          animation: _progressController,
                                          builder: (_, __) => LinearProgressIndicator(
                                            value: _progressController.value,
                                            backgroundColor: Colors.white30,
                                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                                            minHeight: 3,
                                          ),
                                        )
                                      : Container(height: 3, color: Colors.white30),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Header row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB39DDB), Color(0xFF7E57C2)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              title.isNotEmpty ? title[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type == 'note' ? 'My Notes' : 'Linked Notes',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              Text(
                                _formatDate(createdAt),
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Story card
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags + read time
                          Row(
                            children: [
                              if (tags.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB39DDB).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tags.first,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$readTime min read',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Content preview
                          Text(
                            content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _openFullNote(context, story),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF5E35B1),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                type == 'linked' ? 'Open Link →' : 'Read Full Note →',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
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

  Future<void> _openFullNote(BuildContext context, Map<String, dynamic> story) async {
    _progressController.stop();
    final type = story['type'] as String;
    final id = story['id'] as String;

    await _markRead();

    if (type == 'linked') {
      final url = story['url'] as String?;
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } else {
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RichNoteEditorScreen(noteId: id)),
        );
      }
    }

    if (context.mounted) Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
