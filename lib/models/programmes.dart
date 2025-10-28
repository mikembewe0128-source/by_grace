// File: models/programmes.dart

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
  final bool isFromGoogleCalendar;

  Programme({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.description,
    this.location,
    this.imageUrl,
    this.visible = true,
    this.isFromGoogleCalendar = false,
  });

  /// Firestore constructor
  factory Programme.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
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
      isFromGoogleCalendar: false,
    );
  }

  /// JSON constructor (for loading from cache)
  factory Programme.fromJson(Map<String, dynamic> json) {
    return Programme(
      id: json['id'] as String? ?? 'cached-id',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      start:
          DateTime.tryParse(json['start'] as String? ?? '') ?? DateTime.now(),
      end: (json['end'] != null)
          ? DateTime.tryParse(json['end'] as String)
          : null,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      visible: json['visible'] as bool? ?? true,
      isFromGoogleCalendar: json['isFromGoogleCalendar'] as bool? ?? false,
    );
  }

  /// Convert to JSON (for saving to cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start': start.toIso8601String(),
      'end': end?.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'visible': visible,
      'isFromGoogleCalendar': isFromGoogleCalendar,
    };
  }
}
