import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../widgets/story_viewer_screen.dart';

// Unread ring: lavender → rose → amber (Instagram-style pop)
const _unreadGradient = LinearGradient(
  colors: [Color(0xFFCE93D8), Color(0xFFFF6B9D), Color(0xFFFFB347)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Linked ring: lavender → cyan pop
const _linkedGradient = LinearGradient(
  colors: [Color(0xFF9575CD), Color(0xFF26C6DA), Color(0xFF7E57C2)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
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

  void _openViewer(List<Map<String, dynamic>> stories, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(stories: stories, initialIndex: index),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7E57C2), Color(0xFFB39DDB), Color(0xFFCE93D8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_stories, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Memora Stories',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5)),
                              const Text(
                                'Turn information into knowledge, and knowledge into intelligence',
                                style: TextStyle(color: Colors.white70, fontSize: 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: const Color(0xFF7E57C2),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFB39DDB))),
            )
          else if (_notes.isEmpty && _linked.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFCE93D8).withOpacity(0.3),
                            const Color(0xFFB39DDB).withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.auto_stories,
                          size: 64, color: Color(0xFFB39DDB)),
                    ),
                    const SizedBox(height: 20),
                    const Text('No stories yet',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7E57C2))),
                    const SizedBox(height: 8),
                    Text('Save notes or linked notes to see them here',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Your Stories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A148C),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_notes.isNotEmpty)
                        _GroupCircle(
                          label: 'My Notes',
                          icon: Icons.book_rounded,
                          stories: _notes,
                          isLinked: false,
                          onTap: () => _openViewer(_notes, 0),
                        ),
                      if (_linked.isNotEmpty)
                        _GroupCircle(
                          label: 'Linked Notes',
                          icon: Icons.link_rounded,
                          stories: _linked,
                          isLinked: true,
                          onTap: () => _openViewer(_linked, 0),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Stats row
                  Row(
                    children: [
                      if (_notes.isNotEmpty)
                        Expanded(child: _StatsCard(
                          label: 'Notes',
                          total: _notes.length,
                          read: _notes.where((s) => s['isRead'] == true).length,
                          gradient: _unreadGradient,
                        )),
                      if (_notes.isNotEmpty && _linked.isNotEmpty)
                        const SizedBox(width: 12),
                      if (_linked.isNotEmpty)
                        Expanded(child: _StatsCard(
                          label: 'Linked',
                          total: _linked.length,
                          read: _linked.where((s) => s['isRead'] == true).length,
                          gradient: _linkedGradient,
                        )),
                    ],
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupCircle extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Map<String, dynamic>> stories;
  final bool isLinked;
  final VoidCallback onTap;

  const _GroupCircle({
    required this.label,
    required this.icon,
    required this.stories,
    required this.isLinked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allRead = stories.every((s) => s['isRead'] == true);
    final unreadCount = stories.where((s) => s['isRead'] != true).length;

    final ringGradient = allRead
        ? LinearGradient(colors: [
            (isLinked ? const Color(0xFF9575CD) : const Color(0xFFCE93D8))
                .withOpacity(0.3),
            (isLinked ? const Color(0xFF26C6DA) : const Color(0xFFFF6B9D))
                .withOpacity(0.3),
          ])
        : isLinked
            ? _linkedGradient
            : _unreadGradient;

    final innerGradient = isLinked
        ? const LinearGradient(
            colors: [Color(0xFFCE93D8), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFCE93D8), Color(0xFFF48FB1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ringGradient,
                  boxShadow: allRead
                      ? []
                      : [
                          BoxShadow(
                            color: (isLinked
                                    ? const Color(0xFF64B5F6)
                                    : const Color(0xFFF48FB1))
                                .withOpacity(0.5),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3E8FF),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: innerGradient,
                    ),
                    child: Center(
                      child: Icon(icon, size: 38, color: Colors.white),
                    ),
                  ),
                ),
              ),
              // Unread badge
              if (!allRead)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isLinked ? _linkedGradient : _unreadGradient,
                    border: Border.all(color: const Color(0xFFF3E8FF), width: 2),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: allRead ? const Color(0xFFB39DDB) : const Color(0xFF5E35B1),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${stories.length} ${stories.length == 1 ? 'story' : 'stories'}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final int total;
  final int read;
  final LinearGradient gradient;

  const _StatsCard({
    required this.label,
    required this.total,
    required this.read,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final unread = total - read;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem('Total', total, Colors.grey),
              _statItem('Read', read, const Color(0xFF7E57C2)),
              _statItem('Unread', unread, const Color(0xFFFF6B9D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
