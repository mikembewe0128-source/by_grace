import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String? outcome;
  final List<String> outcomeImages;
  final DateTime? startTime; // 🕒
  final DateTime? endTime; // 🕓
  final String? email; // 📧
  final String? contact; // ☎️
  final String? location; // 📍 new

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
    this.outcome,
    required this.outcomeImages,
    this.startTime,
    this.endTime,
    this.email,
    this.contact,
    this.location,
  });

  factory Event.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> images = [];

    if (data['outcomeImages'] != null) {
      if (data['outcomeImages'] is String) {
        final raw = data['outcomeImages'] as String;
        images = raw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (data['outcomeImages'] is List) {
        images = List<String>.from(data['outcomeImages']);
      }
    }

    return Event(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] != null && data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      imageUrl: data['imageUrl'] ?? '',
      outcome: data['outcome'],
      outcomeImages: images,
      startTime: data['startTime'] != null && data['startTime'] is Timestamp
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null && data['endTime'] is Timestamp
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      email: data['email'],
      contact: data['contact'],
      location: data['location'], // ✅ new
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
      'startTime': startTime,
      'endTime': endTime,
      'email': email,
      'contact': contact,
      'location': location, // ✅ new
    };
  }
}
