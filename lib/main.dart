import 'dart:async';
import 'package:diamond_car_clinic/customer/Home.dart';
import 'package:diamond_car_clinic/authencation/onboarding.dart';
import 'package:diamond_car_clinic/authencation/waiting.dart';
import 'package:diamond_car_clinic/authencation/login.dart';
import 'package:diamond_car_clinic/admin/admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diamond Car Clinic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Authentication handling widget
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;
  StreamSubscription<User?>? _authSubscription; // Subscription for auth state
  bool _isLoading = true; // Loading state to show CircularProgressIndicator

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel subscription when widget is disposed
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Listen for Firebase Auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (!mounted) return; // Safeguard for disposed widget

      if (user == null) {
        // No user is logged in, navigate to LoginPage
        setState(() {
          _isLoading = false;
        });
        _navigateToLoginPage();
      } else {
        // User is logged in, handle redirection based on Firestore user data
        _user = user;
        await _handleUserRedirect(user);
      }
    }, onError: (error) {
      print('Auth state error: $error');
      setState(() {
        _isLoading = false;
      });
      _navigateToLoginPage();
    });
  }

  Future<void> _handleUserRedirect(User user) async {
    try {
      // Fetch user data from Firestore
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return; // Safeguard for disposed widget

      if (userData.exists) {
        bool firstTimeUser = userData['firstTimeUser'] ?? true;
        bool isVerified = userData['verified'] ?? false;
        bool isAdmin = userData['isAdmin'] ?? false; // Check for admin status

        // Handle different user cases (admin, unverified, first-time user, etc.)
        if (isAdmin) {
          _navigateToAdminDashboard();
        } else if (!isVerified) {
          _navigateToWaitingScreen(user.uid);
        } else if (isVerified && firstTimeUser) {
          _navigateToOnboardingScreen(user.uid);
        } else {
          _navigateToHomePage();
        }
      } else {
        // User data not found in Firestore, navigate to login page
        setState(() {
          _isLoading = false;
        });
        _navigateToLoginPage();
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        _isLoading = false;
      });
      _navigateToLoginPage();
    }
  }

  // Navigation helper methods
  void _navigateToLoginPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  void _navigateToAdminDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    });
  }

  void _navigateToWaitingScreen(String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WaitingScreen(userId: userId)),
      );
    });
  }

  void _navigateToOnboardingScreen(String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(
            onComplete: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({'firstTimeUser': false});
              _navigateToHomePage();
            },
          ),
        ),
      );
    });
  }

  void _navigateToHomePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Container(), // Display a loading indicator while awaiting auth state
      ),
    );
  }
}
