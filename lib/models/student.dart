// ----------------------------------------------------------------------
// FILE: lib/models/student.dart (Verified Structure)
// ----------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String className;
  final String parentName; // <-- Ensure this field exists
  final String parentContact; // <-- Ensure this field exists
  // ... (Other fields like parentEmail, etc.)

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.parentName,
    required this.parentContact,
    // ...
  });

  // Factory constructor for creating a new Student instance from a Firestore document
  factory Student.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Student(
      id: snapshot.id,
      name: data['name'] ?? '',
      className: data['class_name'] ?? '',
      parentName: data['parent_name'] ?? '', // <-- Mapping from Firestore field
      parentContact:
          data['parent_contact'] ?? '', // <-- Mapping from Firestore field
      // ...
    );
  }

  // Method for converting a Student instance into data suitable for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'class_name': className,
      'parent_name': parentName,
      'parent_contact': parentContact,
      // ...
    };
  }
}
