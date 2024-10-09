class UserModel {
  String uid;
  String email;
  String fullName;
  bool verified;
  bool firstTimeUser; // Attribute to track first-time users
  bool isAdmin; // Field to check if user is an admin
  String carRegistrationNumber; // New field for car registration
  String address; // New field for address
  String phoneNumber; // New field for phone number
  String customerPhotoUrl; // New field for customer photo URL
  String carPhotoUrl; // New field for car photo URL

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.verified = false,
    this.firstTimeUser = true, // Default to true for new users
    this.isAdmin = false, // Default to false for new users
    required this.carRegistrationNumber,
    required this.address,
    required this.phoneNumber,
    required this.customerPhotoUrl,
    required this.carPhotoUrl,
  });

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'verified': verified,
      'firstTimeUser': firstTimeUser, // Add the new attribute
      'isAdmin': isAdmin, // Add the admin check
      'carRegistrationNumber': carRegistrationNumber, // Add car registration
      'address': address, // Add address
      'phoneNumber': phoneNumber, // Add phone number
      'customerPhotoUrl': customerPhotoUrl, // Add customer photo URL
      'carPhotoUrl': carPhotoUrl, // Add car photo URL
    };
  }

  // Construct UserModel from Firestore data
  UserModel.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        email = map['email'],
        fullName = map['fullName'],
        verified = map['verified'] ?? false,
        firstTimeUser = map['firstTimeUser'] ?? true, // Default to true if not present
        isAdmin = map['isAdmin'] ?? false, // Default to false if not present
        carRegistrationNumber = map['carRegistrationNumber'] ?? '',
        address = map['address'] ?? '',
        phoneNumber = map['phoneNumber'] ?? '',
        customerPhotoUrl = map['customerPhotoUrl'] ?? '',
        carPhotoUrl = map['carPhotoUrl'] ?? '';
}
