import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../services/share_service.dart';

class RichNoteEditorScreen extends StatefulWidget {
  final String? noteId;

  const RichNoteEditorScreen({super.key, this.noteId});

  @override
  State<RichNoteEditorScreen> createState() => _RichNoteEditorScreenState();
}

class _RichNoteEditorScreenState extends State<RichNoteEditorScreen> {
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  List<String> _tags = [];
  String _category = 'Personal';
  Color? _backgroundColor;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    _quillController = quill.QuillController.basic();
    if (widget.noteId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<NotesProvider>();
        await provider.loadRichContent(widget.noteId!);
        final note = provider.getNoteById(widget.noteId!);
        if (note != null) {
          _titleController.text = note.title;
          setState(() {
            _tags = List.from(note.tags);
            _category = note.category;
            _backgroundColor = note.backgroundColor;
          });
          if (note.richContent != null && note.richContent!.isNotEmpty) {
            try {
              final doc = quill.Document.fromJson(jsonDecode(note.richContent!));
              setState(() {
                _quillController = quill.QuillController(
                  document: doc,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              });
            } catch (_) {}
          } else if (note.content.isNotEmpty) {
            _quillController.document.insert(0, note.content);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final plainText = _quillController.document.toPlainText().trim();
    final richContent = jsonEncode(_quillController.document.toDelta().toJson());

    if (title.isEmpty && plainText.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final notesProvider = context.read<NotesProvider>();

    if (_isEditing && widget.noteId != null) {
      notesProvider.updateNote(
        widget.noteId!,
        title,
        plainText,
        richContent: richContent,
        tags: _tags,
        category: _category,
        backgroundColor: _backgroundColor,
      );
    } else {
      final note = Note(
        id: '',
        title: title,
        content: plainText,
        richContent: richContent,
        tags: _tags,
        category: _category,
        backgroundColor: _backgroundColor,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      notesProvider.addNote(note);
    }

    Navigator.pop(context);
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  void _addTag() {
    final TextEditingController tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && !_tags.contains(value.trim())) {
              setState(() => _tags.add(value.trim()));
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['Personal', 'Work', 'Study', 'Ideas', 'Shared', 'Other'].map((cat) => 
              ListTile(
                title: Text(cat),
                trailing: _category == cat ? const Icon(Icons.check, color: Color(0xFFB39DDB)) : null,
                onTap: () {
                  setState(() => _category = cat);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackgroundColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Note Background Color'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _backgroundColor ?? Colors.white,
            onColorChanged: (color) {
              setState(() => _backgroundColor = color);
              Navigator.pop(context);
            },
            availableColors: [
              Colors.white,
              const Color(0xFFFFF9C4),
              const Color(0xFFFFCCBC),
              const Color(0xFFE1BEE7),
              const Color(0xFFB2DFDB),
              const Color(0xFFC5E1A5),
              const Color(0xFFFFE0B2),
              const Color(0xFFF8BBD0),
              const Color(0xFFB3E5FC),
              const Color(0xFFD1C4E9),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _backgroundColor = null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _insertImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final index = _quillController.selection.baseOffset;
      final length = _quillController.selection.extentOffset - index;
      _quillController.replaceText(index, length, quill.BlockEmbed.image(image.path), null);
    }
  }

  Future<void> _insertLink() async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController textController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Link'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Link Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = textController.text.trim();
              final url = urlController.text.trim();
              if (text.isNotEmpty && url.isNotEmpty) {
                final index = _quillController.selection.baseOffset;
                _quillController.replaceText(index, 0, text, null);
                _quillController.formatText(index, text.length, quill.LinkAttribute(url));
              }
              Navigator.pop(context);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  void _clearFormatting() {
    final selection = _quillController.selection;
    if (selection.baseOffset != selection.extentOffset) {
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.italic, null));
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.underline, null));
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.strikeThrough, null));
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.color, null));
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.background, null));
    }
  }

  void _shareNote() {
    final title = _titleController.text.trim();
    final content = _quillController.document.toPlainText().trim();
    if (title.isNotEmpty || content.isNotEmpty) {
      final note = Note(
        id: widget.noteId ?? '',
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      ShareService.shareNote(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor ?? const Color(0xFFF3E8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E35B1)),
          onPressed: _saveNote,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette, color: Color(0xFF5E35B1)),
            onPressed: _showBackgroundColorPicker,
            tooltip: 'Background Color',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF5E35B1)),
            onPressed: _shareNote,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFF5E35B1)),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E35B1),
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                InkWell(
                  onTap: _showCategoryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB39DDB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _category,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._tags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 11)),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(() => _tags.remove(tag)),
                            backgroundColor: const Color(0xFFE1BEE7),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFB39DDB)),
                          onPressed: _addTag,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Container(
            color: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: quill.QuillSimpleToolbar(
              controller: _quillController,
              config: const quill.QuillSimpleToolbarConfig(
                showAlignmentButtons: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
                showCodeBlock: true,
                showColorButton: true,
                showDirection: false,
                showDividers: true,
                showFontFamily: false,
                showFontSize: false,
                showHeaderStyle: true,
                showIndent: true,
                showInlineCode: true,
                showLink: true,
                showListBullets: true,
                showListCheck: true,
                showListNumbers: true,
                showQuote: true,
                showSearchButton: false,
                showSmallButton: false,
                showStrikeThrough: true,
                showSubscript: false,
                showSuperscript: false,
                showUnderLineButton: true,
                multiRowsDisplay: false,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, size: 20),
                  color: const Color(0xFF5E35B1),
                  onPressed: _insertImage,
                  tooltip: 'Insert Image',
                ),
                IconButton(
                  icon: const Icon(Icons.link, size: 20),
                  color: const Color(0xFF5E35B1),
                  onPressed: _insertLink,
                  tooltip: 'Insert Link',
                ),
                IconButton(
                  icon: const Icon(Icons.format_clear, size: 20),
                  color: const Color(0xFF5E35B1),
                  onPressed: _clearFormatting,
                  tooltip: 'Clear Formatting',
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB39DDB).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: quill.QuillEditor.basic(
                controller: _quillController,
                config: const quill.QuillEditorConfig(
                  placeholder: 'Start writing your note...',
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
