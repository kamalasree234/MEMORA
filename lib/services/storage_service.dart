import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String?> uploadRichContent(String uid, String noteId, String jsonContent) async {
    try {
      final ref = _storage.ref('users/$uid/notes/$noteId.json');
      final bytes = utf8.encode(jsonContent);
      await ref.putData(bytes, SettableMetadata(contentType: 'application/json'));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<String?> downloadRichContent(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      final bytes = await ref.getData();
      if (bytes == null) return null;
      return utf8.decode(bytes);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteRichContent(String uid, String noteId) async {
    try {
      await _storage.ref('users/$uid/notes/$noteId.json').delete();
    } catch (_) {}
  }
}
