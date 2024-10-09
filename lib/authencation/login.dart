import 'package:diamond_car_clinic/customer/Home.dart';
import 'package:diamond_car_clinic/authencation/onboarding.dart';
import 'package:diamond_car_clinic/authencation/signup.dart';
import 'package:diamond_car_clinic/authencation/waiting.dart';
import 'package:diamond_car_clinic/admin/admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userData.exists) {
          bool firstTimeUser = userData['firstTimeUser'] ?? true;
          bool isVerified = userData['verified'] ?? false;
          bool isAdmin = userData['isAdmin'] ?? false; // Check for admin status

          if (isAdmin) {
          // Redirect admin user to Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()), // Change to your Admin Dashboard widget
          );
        } else if (!isVerified) {
            // User is not verified, send them to the Waiting screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WaitingScreen(userId: user.uid)),
            );
          } else if (firstTimeUser) {
            // First-time user, show onboarding
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OnboardingScreen(
                  onComplete: () async {
                    // Mark user as not a first-time user after onboarding
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'firstTimeUser': false});

                    // Navigate to the Home Page after onboarding
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
              ),
            );
          } else {
            // Regular verified user, go to the Home Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  // Forgot password logic
  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to your email.')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  // Navigate to the Sign Up page
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
            ],
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _resetPassword,
              child: Text('Forgot Password?'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _navigateToSignUp,
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
