import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateModel {
  String id; // Firestore document ID for the update
  String bookingId; // ID of the booking the update is related to
  String message; // Update message
  Timestamp estimatedDate; // Estimated completion date
  Timestamp timestamp; // Timestamp for when the update was created
  String customerEmail; // Customer email to notify about updates
  List<String> photos; // List of photo URLs related to the update

  UpdateModel({
    required this.id,
    required this.bookingId,
    required this.message,
    required this.estimatedDate,
    required this.timestamp,
    required this.customerEmail,
    required this.photos, // Add photos list to the model
  });

  // Convert UpdateModel to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'message': message,
      'estimatedDate': estimatedDate,
      'timestamp': timestamp,
      'customerEmail': customerEmail,
      'photos': photos, // Include photos in the map
    };
  }

  // Convert a Firestore document to an UpdateModel
  factory UpdateModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UpdateModel(
      id: doc.id, // Get the document ID
      bookingId: data['bookingId'] ?? '',
      message: data['message'] ?? '',
      estimatedDate: data['estimatedDate'] ?? Timestamp.now(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      customerEmail: data['customerEmail'] ?? '',
      photos: List<String>.from(data['photos'] ?? []), // Retrieve photos list
    );
  }
}
