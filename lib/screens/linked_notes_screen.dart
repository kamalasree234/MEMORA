import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/linked_notes_provider.dart';
import '../models/linked_note.dart';
import '../widgets/notification_sheet.dart';

class LinkedNotesScreen extends StatelessWidget {
  const LinkedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7E57C2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Linked Notes',
          style: TextStyle(
            color: Color(0xFF7E57C2),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link, color: Color(0xFF7E57C2)),
            onPressed: () => _showAddLinkDialog(context),
          ),
        ],
      ),
      body: Consumer<LinkedNotesProvider>(
        builder: (context, provider, child) {
          if (provider.linkedNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.link_off,
                    size: 80,
                    color: const Color(0xFFB39DDB).withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No linked notes yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share links to Memora to save them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.linkedNotes.length,
            itemBuilder: (context, index) {
              final note = provider.linkedNotes[index];
              return _buildLinkedNoteCard(context, note, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildLinkedNoteCard(BuildContext context, LinkedNote note, LinkedNotesProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            const Color(0xFFE1BEE7).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1BEE7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB39DDB).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLinkedNote(context, note),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB39DDB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.link,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.siteName != null)
                            Text(
                              note.siteName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF7E57C2).withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5E35B1),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'remind',
                          child: Row(children: [
                            Icon(Icons.notifications, size: 20, color: Color(0xFF9575CD)),
                            SizedBox(width: 8),
                            Text('Set Reminder'),
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'open',
                          child: Row(
                            children: [
                              Icon(Icons.open_in_new, size: 20),
                              SizedBox(width: 8),
                              Text('Open Link'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'remind') {
                          NotificationSheet.show(context,
                            noteId: note.id,
                            noteTitle: note.title,
                            noteType: 'linked');
                        } else if (value == 'open') {
                          _launchUrl(note.url);
                        } else if (value == 'delete') {
                          provider.deleteLinkedNote(note.id);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF5E35B1).withOpacity(0.8),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1BEE7).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: const Color(0xFF7E57C2).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(note.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF7E57C2).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLinkedNote(BuildContext context, LinkedNote note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LinkedNoteDetailScreen(note: note),
      ),
    );
  }

  void _showAddLinkDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3E8FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Link',
          style: TextStyle(color: Color(0xFF7E57C2), fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter URL',
            prefixIcon: const Icon(Icons.link, color: Color(0xFFB39DDB)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1BEE7)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF7E57C2))),
          ),
          ElevatedButton(
            onPressed: () async {
              final urlText = controller.text.trim();
              if (urlText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a URL'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (!urlText.startsWith('http://') && !urlText.startsWith('https://')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL must start with http:// or https://'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              final provider = context.read<LinkedNotesProvider>();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Extracting content...'),
                  backgroundColor: Color(0xFFB39DDB),
                  duration: Duration(seconds: 2),
                ),
              );
              
              final success = await provider.addLinkedNoteFromUrl(urlText);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Link saved successfully!' : 'Failed to extract content. Check console for details.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB39DDB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class LinkedNoteDetailScreen extends StatelessWidget {
  final LinkedNote note;

  const LinkedNoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7E57C2)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Color(0xFF7E57C2)),
            onPressed: () => _launchUrl(note.url),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    const Color(0xFFE1BEE7).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE1BEE7), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB39DDB).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB39DDB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.link, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.siteName != null)
                              Text(
                                note.siteName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF7E57C2).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              note.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E35B1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE1BEE7)),
                  const SizedBox(height: 20),
                  Text(
                    note.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF5E35B1).withOpacity(0.9),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => _launchUrl(note.url),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1BEE7).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.open_in_new, size: 16, color: Color(0xFF7E57C2)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.url,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7E57C2),
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
