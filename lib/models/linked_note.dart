import 'package:cloud_firestore/cloud_firestore.dart';

class LinkedNote {
  final String id;
  String title;
  String content;
  String url;
  String? siteName;
  String? description;
  bool isRead;
  DateTime? readAt;
  DateTime createdAt;
  DateTime updatedAt;

  LinkedNote({
    required this.id,
    required this.title,
    required this.content,
    required this.url,
    this.siteName,
    this.description,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'url': url,
      'siteName': siteName,
      'description': description,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LinkedNote.fromMap(String docId, Map<String, dynamic> map) {
    return LinkedNote(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      url: map['url'] ?? '',
      siteName: map['siteName'],
      description: map['description'],
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
