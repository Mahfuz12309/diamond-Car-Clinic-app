import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias for FirebaseAuth// Ensure this path is correct and rename User to UserModel

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance; // Use the alias
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp(String email, String password, String fullName) async {
    try {
      // Create user in Firebase Authentication
      firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a user object using your UserModel
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        verified: false, // Set initial verified status
        firstTimeUser: true, // Default to true for new users
        isAdmin: false, // Default to not admin
        carRegistrationNumber: '', // Initialize as needed
        address: '', // Initialize as needed
        phoneNumber: '', // Initialize as needed
        customerPhotoUrl: '', // Initialize as needed
        carPhotoUrl: '', // Initialize as needed
      );

      // Save user to Firestore
      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
    } catch (e) {
      print(e.toString());
      throw e; // Handle errors as needed
    }
  }

  Future<firebase_auth.User?> signIn(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      throw e; // Handle errors as needed
    }
  }

  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print(e.toString());
      throw e; // Handle errors as needed
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
      throw e; // Handle errors as needed
    }
  }
}
