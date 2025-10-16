import 'package:cloud_firestore/cloud_firestore.dart';

class Devotion {
  final String title;
  final String scripture;
  final String message;
  final String imageUrl;
  final DateTime date;
  final DateTime? updatedAt;
  final String author; // ✨ NEW: Field for the devotion's author/sharer

  Devotion({
    required this.title,
    required this.scripture,
    required this.message,
    required this.imageUrl,
    required this.date,
    this.updatedAt,
    required this.author, // ✨ NEW: Add to constructor
  });

  factory Devotion.fromJson(Map<String, dynamic> json) {
    return Devotion(
      title: json['title'] ?? '',
      scripture: json['scripture'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: (json['date'] as Timestamp)
          .toDate(), // convert Timestamp -> DateTime
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      // ✨ NEW: Read the author field from Firestore (if present)
      author: json['author'] ?? 'Ministry Team',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'scripture': scripture,
      'message': message,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(), // DateTime -> String for local storage
      'updatedAt': updatedAt?.toIso8601String(), // DateTime -> String
      // ✨ NEW: Include author for local storage save
      'author': author,
    };
  }

  // For loading from local storage (SharedPreferences)
  factory Devotion.fromLocalJson(Map<String, dynamic> json) {
    return Devotion(
      title: json['title'] ?? '',
      scripture: json['scripture'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: DateTime.parse(json['date']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      // ✨ NEW: Read the author field from local storage
      author: json['author'] ?? 'Ministry Team',
    );
  }
}
