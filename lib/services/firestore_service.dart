import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import '../models/linked_note.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _notes(String uid) =>
      _db.collection('users').doc(uid).collection('notes');

  CollectionReference _linkedNotes(String uid) =>
      _db.collection('users').doc(uid).collection('linked_notes');

  // ── Notes ──────────────────────────────────────────

  Stream<List<Note>> notesStream(String uid) {
    return _notes(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Note.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<String> addNote(String uid, Note note) async {
    final doc = await _notes(uid).add(note.toMap());
    return doc.id;
  }

  Future<void> updateNote(String uid, String noteId, Map<String, dynamic> data) async {
    await _notes(uid).doc(noteId).update({
      ...data,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteNote(String uid, String noteId) async {
    await _notes(uid).doc(noteId).delete();
  }

  // ── Linked Notes ───────────────────────────────────

  Stream<List<LinkedNote>> linkedNotesStream(String uid) {
    return _linkedNotes(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => LinkedNote.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<String> addLinkedNote(String uid, LinkedNote note) async {
    final doc = await _linkedNotes(uid).add(note.toMap());
    return doc.id;
  }

  Future<void> deleteLinkedNote(String uid, String noteId) async {
    await _linkedNotes(uid).doc(noteId).delete();
  }

  // ── Stories ────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchStories(String uid) async {
    final noteSnap = await _notes(uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    final linkedSnap = await _linkedNotes(uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    final notes = noteSnap.docs.map((d) => {
      ...d.data() as Map<String, dynamic>,
      'id': d.id,
      'type': 'note',
    }).toList();

    final linked = linkedSnap.docs.map((d) => {
      ...d.data() as Map<String, dynamic>,
      'id': d.id,
      'type': 'linked',
    }).toList();

    final all = [...notes, ...linked];
    all.sort((a, b) {
      final aRead = a['isRead'] == true;
      final bRead = b['isRead'] == true;
      if (aRead != bRead) return aRead ? 1 : -1;
      final aTime = (a['createdAt'] as Timestamp).toDate();
      final bTime = (b['createdAt'] as Timestamp).toDate();
      return bTime.compareTo(aTime);
    });
    return all;
  }

  Future<void> markAsRead(String uid, String noteId, String type) async {
    final col = type == 'note' ? _notes(uid) : _linkedNotes(uid);
    await col.doc(noteId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }
}
