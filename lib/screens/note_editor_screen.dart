import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _category = 'Personal';
  bool _isBold = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    if (widget.noteId != null) {
      final note = context.read<NotesProvider>().getNoteById(widget.noteId!);
      if (note != null) {
        _titleController.text = note.title;
        _contentController.text = note.content;
        _category = note.category;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<NotesProvider>();

    if (widget.noteId != null) {
      provider.updateNote(widget.noteId!, title, content, category: _category);
    } else {
      provider.addNote(Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        category: _category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    Navigator.pop(context);
  }

  void _shareNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isNotEmpty || content.isNotEmpty) {
      Share.share('$title\n\n$content', subject: title);
    }
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesProvider>().deleteNote(widget.noteId!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
          onPressed: _saveNote,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF5E35B1)),
            onPressed: _shareNote,
          ),
          if (widget.noteId != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF5E35B1)),
              onPressed: _deleteNote,
            ),
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF5E35B1)),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _category,
                      items: ['Personal', 'Work', 'Study'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) => setState(() => _category = value!),
                      style: const TextStyle(color: Color(0xFF5E35B1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.format_bold, color: _isBold ? const Color(0xFF7c3aed) : Colors.grey),
                    onPressed: () => setState(() => _isBold = !_isBold),
                  ),
                  IconButton(
                    icon: Icon(Icons.format_italic, color: _isItalic ? const Color(0xFF7c3aed) : Colors.grey),
                    onPressed: () => setState(() => _isItalic = !_isItalic),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_underlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_color_text, color: Colors.grey),
                    onPressed: () => _showColorPicker(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_clear, color: Colors.grey),
                    onPressed: () => setState(() {
                      _isBold = false;
                      _isItalic = false;
                    }),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                ),
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _colorButton(Colors.black),
            _colorButton(const Color(0xFF7c3aed)),
            _colorButton(const Color(0xFFB39DDB)),
            _colorButton(Colors.red),
            _colorButton(Colors.blue),
            _colorButton(Colors.green),
            _colorButton(Colors.orange),
            _colorButton(Colors.pink),
            _colorButton(Colors.teal),
            _colorButton(Colors.amber),
            _colorButton(Colors.indigo),
            _colorButton(Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
