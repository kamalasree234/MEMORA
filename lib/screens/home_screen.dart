import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/notes_provider.dart';
import 'stories_page.dart';
import 'rich_note_editor_screen.dart';
import 'linked_notes_screen.dart';
import '../widgets/notification_sheet.dart';
import '../services/sharing_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharingHandler.initialize(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // AuthGate listener handles clear() and navigation automatically
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFFF3E8FF),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB39DDB),
                    const Color(0xFF9575CD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'MEMORA.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.book, color: Colors.white, size: 32),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Memora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note, color: Color(0xFF7E57C2)),
              title: const Text(
                'My Notes',
                style: TextStyle(color: Color(0xFF5E35B1), fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Color(0xFF7E57C2)),
              title: const Text(
                'Linked Notes',
                style: TextStyle(color: Color(0xFF5E35B1), fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LinkedNotesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories, color: Color(0xFF7E57C2)),
              title: const Text(
                'Memora Stories',
                style: TextStyle(color: Color(0xFF5E35B1), fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StoriesPage()),
                );
              },
            ),
            const Divider(color: Color(0xFFE1BEE7)),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF7E57C2)),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Color(0xFF5E35B1), fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFF7E57C2)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'MEMORA.jpg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9575CD), Color(0xFF7E57C2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.book, color: Colors.white, size: 28),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Memora',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7E57C2),
                    ),
                  ),
                  const Spacer(),
                  if (user != null)
                    PopupMenuButton(
                      icon: CircleAvatar(
                        backgroundColor: const Color(0xFFB39DDB),
                        child: Text(
                          userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          enabled: false,
                          child: Text(userEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20),
                              SizedBox(width: 8),
                              Text('Sign Out'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'logout') _logout();
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9575CD)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE1BEE7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE1BEE7)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['All', 'Personal', 'Work', 'Study'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = cat);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFB39DDB),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF7E57C2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<NotesProvider>(
                builder: (context, provider, child) {
                  var notes = provider.notes;

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    notes = notes.where((note) {
                      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          note.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
                    }).toList();
                  }

                  // Apply category filter
                  if (_selectedCategory != 'All') {
                    notes = notes.where((note) => note.category == _selectedCategory).toList();
                  }

                  if (notes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty ? Icons.search_off : Icons.note_outlined,
                            size: 80,
                            color: const Color(0xFFB39DDB).withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ? 'No results found' : 'No notes yet',
                            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty ? 'Try different keywords' : 'Tap + to create your first note',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: note.backgroundColor ?? Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE1BEE7), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB39DDB).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB39DDB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  note.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButton<String>(
                              icon: Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                              color: const Color(0xFFF3E8FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'remind', child: Row(children: [Icon(Icons.notifications, color: Color(0xFF9575CD), size: 18), SizedBox(width: 8), Text('Set Reminder')])),
                              ],
                              onSelected: (val) {
                                if (val == 'remind') {
                                  NotificationSheet.show(context,
                                    noteId: note.id,
                                    noteTitle: note.title,
                                    noteType: 'note');
                                }
                              },
                            ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                note.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF5E35B1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                              if (note.tags.isNotEmpty)
                                const SizedBox(height: 8),
                              if (note.tags.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  children: note.tags.take(3).map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE1BEE7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(
                                        color: Color(0xFF5E35B1),
                                        fontSize: 10,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RichNoteEditorScreen(noteId: note.id),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB39DDB).withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RichNoteEditorScreen()),
            ),
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
