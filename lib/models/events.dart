import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String? outcome;
  final List<String> outcomeImages; // Non-nullable list

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
    this.outcome,
    required this.outcomeImages,
  });

  factory Event.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> images = [];

    // ✅ Handle both correct list and incorrectly formatted string
    if (data['outcomeImages'] != null) {
      if (data['outcomeImages'] is String) {
        // Convert string "[url1, url2]" to List<String>
        final raw = data['outcomeImages'] as String;
        images = raw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (data['outcomeImages'] is List) {
        // Proper list from Firestore
        images = List<String>.from(data['outcomeImages']);
      }
    }

    return Event(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      outcome: data['outcome'],
      outcomeImages: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'imageUrl': imageUrl,
      'outcome': outcome,
      'outcomeImages': outcomeImages,
    };
  }
}
