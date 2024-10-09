import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String id; // Firestore document ID
  String userId; // ID of the user making the booking
  String name;
  String carRegistrationNumber;
  String phoneNumber;
  String address;
  String bookingDate;
  String bookingTime;
  List<String> carPhotos;
  String email; // New field for storing email
   Timestamp timestamp; // Field for storing timestamp

  ServiceModel({
    required this.id,
    required this.userId, // Add user ID
    required this.name,
    required this.carRegistrationNumber,
    required this.phoneNumber,
    required this.address,
    required this.bookingDate,
    required this.bookingTime,
    required this.carPhotos,
    required this.email, // Include email in constructor
    required this.timestamp, // Include timestamp in constructor
  });

  // Convert ServiceModel to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // Store user ID
      'name': name,
      'carRegistrationNumber': carRegistrationNumber,
      'phoneNumber': phoneNumber,
      'address': address,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'carPhotos': carPhotos,
      'email': email, // Include email in the map
      'timestamp': timestamp, // Include timestamp in the map
      
    };
  }

  // Convert a Firestore document to a ServiceModel
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id, // Get the document ID
      userId: data['userId'] ?? '', // Retrieve user ID
      name: data['name'] ?? '',
      carRegistrationNumber: data['carRegistrationNumber'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      bookingDate: data['bookingDate'] ?? '',
      bookingTime: data['bookingTime'] ?? '',
      carPhotos: List<String>.from(data['carPhotos'] ?? []),
       email: data['email'], // Include email in fromMap
        timestamp: data['timestamp'] ?? Timestamp.now(), // Include timestamp
    );
  }
}
