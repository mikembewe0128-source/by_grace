import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  // MODIFIED: Change type from Timestamp to DateTime for Flutter UI use
  final DateTime date;
  final String content;
  final String imageUrl;
  // NEW: Field for the announcement sender/sharer
  final String sender;

  Announcement({
    required this.id,
    required this.title,
    // MODIFIED: Update constructor type
    required this.date,
    required this.content,
    required this.imageUrl,
    // NEW: Add sender to constructor
    required this.sender,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper to safely get the date and convert the Firestore Timestamp to DateTime
    Timestamp timestamp = data['date'] ?? Timestamp.now();

    return Announcement(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      // CRITICAL: Convert the Timestamp to a DateTime object
      date: timestamp.toDate(),
      content: data['content'] ?? 'No content available.',
      imageUrl: data['imageUrl'] ?? '',
      // NEW: Retrieve sender from Firestore data
      sender: data['sender'] ?? 'Unknown Sender',
    );
  }

  // OPTIONAL: A method to convert the object back to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'content': content,
      'imageUrl': imageUrl,
      'sender': sender,
    };
  }
}
