import 'package:cloud_firestore/cloud_firestore.dart';

class Programme {
  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime? end;
  final String? location;
  final String? imageUrl;
  final bool visible;

  Programme({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.description,
    this.location,
    this.imageUrl,
    this.visible = true,
  });

  factory Programme.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now(); // fallback for invalid/missing values
    }

    return Programme(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String?,
      start: parseTimestamp(data['start']),
      end: data['end'] != null ? parseTimestamp(data['end']) : null,
      location: data['location'] as String?,
      imageUrl: data['imageUrl'] as String?,
      visible: data['visible'] as bool? ?? true,
    );
  }
}
