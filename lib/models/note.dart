import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Note {
  final String id;
  String title;
  String content;
  String? richContent;
  String? richContentUrl;
  String category;
  List<String> tags;
  Color? backgroundColor;
  DateTime createdAt;
  DateTime updatedAt;
  String? linkUrl;
  Map<String, dynamic>? linkMetadata;
  bool isRead;
  DateTime? readAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.richContent,
    this.richContentUrl,
    this.category = 'Personal',
    this.tags = const [],
    this.backgroundColor,
    required this.createdAt,
    required this.updatedAt,
    this.linkUrl,
    this.linkMetadata,
    this.isRead = false,
    this.readAt,
  });

  bool get isLinkNote => linkUrl != null;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'richContentUrl': richContentUrl,
      'category': category,
      'tags': tags,
      'backgroundColor': backgroundColor?.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'linkUrl': linkUrl,
      'linkMetadata': linkMetadata,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  factory Note.fromMap(String docId, Map<String, dynamic> map) {
    return Note(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      richContentUrl: map['richContentUrl'],
      category: map['category'] ?? 'Personal',
      tags: List<String>.from(map['tags'] ?? []),
      backgroundColor: map['backgroundColor'] != null ? Color(map['backgroundColor']) : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      linkUrl: map['linkUrl'],
      linkMetadata: map['linkMetadata'] != null ? Map<String, dynamic>.from(map['linkMetadata']) : null,
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
    );
  }
}
