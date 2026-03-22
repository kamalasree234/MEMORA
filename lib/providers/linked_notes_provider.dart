import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/linked_note.dart';
import '../services/firestore_service.dart';
import '../services/microlink_service.dart';
import '../services/notification_service.dart';

class LinkedNotesProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();

  List<LinkedNote> _linkedNotes = [];
  StreamSubscription? _subscription;
  String? _uid;

  List<LinkedNote> get linkedNotes => List.unmodifiable(_linkedNotes);

  void init(String uid) {
    _subscription?.cancel();
    _uid = uid;
    _linkedNotes = [];
    notifyListeners();
    _subscription = _firestoreService.linkedNotesStream(uid).listen((notes) {
      _linkedNotes = notes;
      notifyListeners();
    });
  }

  void clear() {
    _uid = null;
    _subscription?.cancel();
    _subscription = null;
    _linkedNotes = [];
    notifyListeners();
  }

  Future<bool> addLinkedNoteFromUrl(String url) async {
    if (_uid == null) return false;
    if (!MicrolinkService.isValidUrl(url)) return false;

    final content = await MicrolinkService.extractContent(url);
    if (content == null) return false;

    final linkedNote = LinkedNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: content['title'] ?? 'Untitled',
      content: content['content'] ?? content['description'] ?? 'No content available',
      url: url,
      siteName: content['siteName'],
      description: content['description'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final docId = await _firestoreService.addLinkedNote(_uid!, linkedNote);
    await NotificationService.scheduleReminders(docId, linkedNote.title, 'linked');
    return true;
  }

  Future<void> deleteLinkedNote(String id) async {
    if (_uid == null) return;
    await _firestoreService.deleteLinkedNote(_uid!, id);
    await NotificationService.cancelReminders(id);
  }

  LinkedNote? getLinkedNoteById(String id) {
    try {
      return _linkedNotes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
