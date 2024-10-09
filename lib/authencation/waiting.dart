import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diamond_car_clinic/authencation/onboarding.dart';
import 'package:diamond_car_clinic/customer/Home.dart';

class WaitingScreen extends StatefulWidget {
  final String userId;

  WaitingScreen({required this.userId});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    _startAutoRefresh();
  }

  // Check verification status every 2 minutes
  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: 10), () async {
      await _checkVerificationStatus();
      if (!_isVerified) {
        _startAutoRefresh();  // Recursively call to check again after 2 minutes
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    if (userData.exists) {
      bool isVerified = userData['verified'] ?? false;

      if (isVerified) {
        bool firstTimeUser = userData['firstTimeUser'] ?? true;
        setState(() {
          _isVerified = true;
        });

        if (firstTimeUser) {
          // User is now verified and it's their first time, go to Onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(
                onComplete: () async {
                  // Mark user as not a first-time user
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .update({'firstTimeUser': false});
                  
                  // Navigate to HomePage after onboarding
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ),
          );
        } else {
          // User is verified and not a first-time user, go to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting for Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please wait, your account is not yet verified.'),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
