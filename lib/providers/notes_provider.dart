import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class NotesProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  List<Note> _notes = [];
  StreamSubscription? _subscription;
  String? _uid;

  List<Note> get notes => List.unmodifiable(_notes);

  void init(String uid) {
    _subscription?.cancel();
    _uid = uid;
    _notes = [];
    notifyListeners();
    _subscription = _firestoreService.notesStream(uid).listen((notes) {
      _notes = notes;
      notifyListeners();
    });
  }

  void clear() {
    _uid = null;
    _subscription?.cancel();
    _subscription = null;
    _notes = [];
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    if (_uid == null) return;
    final docId = await _firestoreService.addNote(_uid!, note);
    if (note.richContent != null && note.richContent!.isNotEmpty) {
      final url = await _storageService.uploadRichContent(_uid!, docId, note.richContent!);
      if (url != null) {
        await _firestoreService.updateNote(_uid!, docId, {'richContentUrl': url});
      }
    }
    await NotificationService.scheduleReminders(docId, note.title, 'note');
  }

  Future<void> updateNote(
    String id,
    String title,
    String content, {
    String? richContent,
    List<String>? tags,
    String? category,
    Color? backgroundColor,
  }) async {
    if (_uid == null) return;
    String? richContentUrl;
    if (richContent != null && richContent.isNotEmpty) {
      richContentUrl = await _storageService.uploadRichContent(_uid!, id, richContent);
    }
    final data = <String, dynamic>{
      'title': title,
      'content': content,
      if (richContentUrl != null) 'richContentUrl': richContentUrl,
      if (tags != null) 'tags': tags,
      if (category != null) 'category': category,
      if (backgroundColor != null) 'backgroundColor': backgroundColor.value,
    };
    await _firestoreService.updateNote(_uid!, id, data);

    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].title = title;
      _notes[index].content = content;
      if (richContent != null) _notes[index].richContent = richContent;
      if (richContentUrl != null) _notes[index].richContentUrl = richContentUrl;
      if (tags != null) _notes[index].tags = tags;
      if (category != null) _notes[index].category = category;
      if (backgroundColor != null) _notes[index].backgroundColor = backgroundColor;
      _notes[index].updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    if (_uid == null) return;
    await _firestoreService.deleteNote(_uid!, id);
    await _storageService.deleteRichContent(_uid!, id);
    await NotificationService.cancelReminders(id);
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadRichContent(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;
    final note = _notes[index];
    if (note.richContent != null) return;
    if (note.richContentUrl == null) return;
    final content = await _storageService.downloadRichContent(note.richContentUrl!);
    if (content != null) {
      _notes[index].richContent = content;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
