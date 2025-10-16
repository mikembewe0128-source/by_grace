import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String to;
  final String sender;
  final String title;
  final String content;
  final DateTime date;
  final String imageUrl;

  Notice({
    required this.id,
    required this.to,
    required this.sender,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl = '',
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Notice(
      id: doc.id,
      to: data['to'] ?? '',
      sender: data['sender'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'to': to,
    'sender': sender,
    'title': title,
    'content': content,
    'date': date.toIso8601String(),
    'imageUrl': imageUrl,
  };

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
    id: json['id'] ?? '',
    to: json['to'] ?? '',
    sender: json['sender'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    imageUrl: json['imageUrl'] ?? '',
  );
}
