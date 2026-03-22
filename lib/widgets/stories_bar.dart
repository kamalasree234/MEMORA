import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'story_viewer_screen.dart';

class StoriesBar extends StatefulWidget {
  const StoriesBar({super.key});

  @override
  State<StoriesBar> createState() => _StoriesBarState();
}

class _StoriesBarState extends State<StoriesBar> {
  final _service = FirestoreService();
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _linked = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final stories = await _service.fetchStories(uid);
    if (!mounted) return;
    setState(() {
      _notes = stories.where((s) => s['type'] == 'note').toList();
      _linked = stories.where((s) => s['type'] == 'linked').toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFB39DDB))),
      );
    }
    if (_notes.isEmpty && _linked.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (_notes.isNotEmpty)
            _SectionCircle(
              label: 'My Notes',
              icon: Icons.note_alt_outlined,
              onTap: () => _openViewer(context, _notes, 0),
            ),
          if (_linked.isNotEmpty)
            _SectionCircle(
              label: 'Linked',
              icon: Icons.link,
              onTap: () => _openViewer(context, _linked, 0),
            ),
          ..._notes.map((s) => _StoryCircle(
                story: s,
                onTap: () => _openViewer(context, _notes, _notes.indexOf(s)),
              )),
          ..._linked.map((s) => _StoryCircle(
                story: s,
                onTap: () => _openViewer(context, _linked, _linked.indexOf(s)),
              )),
        ],
      ),
    );
  }

  void _openViewer(BuildContext context, List<Map<String, dynamic>> stories, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(stories: stories, initialIndex: index),
      ),
    );
    _load(); // refresh read state after viewer closes
  }
}

class _SectionCircle extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SectionCircle({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFB39DDB), Color(0xFF7E57C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF5E35B1), fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final Map<String, dynamic> story;
  final VoidCallback onTap;

  const _StoryCircle({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = story['isRead'] == true;
    final title = (story['title'] as String? ?? '');
    final firstWord = title.split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Opacity(
          opacity: isRead ? 0.5 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isRead
                      ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                      : const LinearGradient(
                          colors: [Color(0xFFB39DDB), Color(0xFF5E35B1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3E8FF),
                  ),
                  child: Center(
                    child: Text(
                      title.isNotEmpty ? title[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7E57C2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 64,
                child: Text(
                  firstWord,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5E35B1)),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
