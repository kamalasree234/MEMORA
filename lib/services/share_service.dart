import 'package:share_plus/share_plus.dart';
import '../models/note.dart';

class ShareService {
  static Future<void> shareNote(Note note) async {
    final text = '${note.title}\n\n${note.content}';
    await Share.share(text, subject: note.title);
  }
  
  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
