import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id; // Firestore document ID
  final String title;
  final List<String> bannerUrls; // List of banner image URLs
  final DateTime expiryTime; // Expiry date and time
  final bool isVisible; // Visibility status
  final DateTime createdAt; // Creation timestamp

  Promotion({
    required this.id,
    required this.title,
    required this.bannerUrls,
    required this.expiryTime,
    required this.isVisible,
    required this.createdAt,
  });

  // Factory method to create a Promotion object from Firestore document data
  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Promotion(
      id: doc.id,
      title: data['title'],
      bannerUrls: List<String>.from(data['bannerUrls'] ?? []),
      expiryTime: (data['expiryTime'] as Timestamp).toDate(),
      isVisible: data['isVisible'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert Promotion object to a Map (for Firestore saving)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'bannerUrls': bannerUrls,
      'expiryTime': Timestamp.fromDate(expiryTime),
      'isVisible': isVisible,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
