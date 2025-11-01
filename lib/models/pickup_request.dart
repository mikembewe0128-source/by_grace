import 'package:cloud_firestore/cloud_firestore.dart';

/// Defines the data structure for a student pickup or drop-off request.
class PickupRequest {
  final String requestId;
  final String studentId;
  final String studentName;
  final String type; // 'Pickup' or 'Dropoff'
  final String status; // 'Pending', 'Picked Up', or 'Dropped Off'
  final DateTime requestTime;
  final String reason;

  PickupRequest({
    required this.requestId,
    required this.studentId,
    required this.studentName,
    required this.type,
    required this.status,
    required this.requestTime,
    required this.reason,
  });

  /// Factory constructor to create a PickupRequest from a Firestore DocumentSnapshot.
  factory PickupRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    // Safely get the data map
    final data = snapshot.data();

    // Safely get the Timestamp, which can be null
    final timestamp = data?['request_time'] as Timestamp?;

    // Determine the ID
    final id = snapshot.id;

    // Determine the student ID (CHECK THE FIELD NAME IN FIREBASE: 'student_id' or 'studentId'?)
    final studentIdField = data?['student_id'] ?? data?['studentId'] ?? '';

    // Determine the student name (CHECK THE FIELD NAME IN FIREBASE: 'student_name' or 'studentName'?)
    final studentNameField =
        data?['student_name'] ?? data?['studentName'] ?? 'Unknown Student';

    return PickupRequest(
      requestId: id,
      studentId: studentIdField as String,
      studentName: studentNameField as String,
      type: data?['type'] ?? 'Pickup',
      status: data?['status'] ?? 'Pending',
      // Safely convert Timestamp to DateTime, or fall back to DateTime.now() if null
      requestTime: timestamp?.toDate() ?? DateTime.now(),
      reason: data?['reason'] ?? 'Routine',
    );
  }

  /// Converts the object to a format ready to be written to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'type': type,
      'status': status,
      'request_time': Timestamp.fromDate(requestTime),
      'reason': reason,
    };
  }
}
