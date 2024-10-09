import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreditPage extends StatefulWidget {
  @override
  _CreditPageState createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _creditBalance = 0.0; // To store the user's credit balance

  @override
  void initState() {
    super.initState();
    _fetchCreditBalance(); // Fetch the credit balance when the page is initialized
  }

  Future<void> _fetchCreditBalance() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _creditBalance = userDoc['creditBalance'] ?? 0.0; // Get credit balance
        });
      }
    }
  }

  Future<void> _redeemCredits(double amount) async {
    if (_creditBalance >= amount) {
      setState(() {
        _creditBalance -= amount; // Deduct amount from balance
      });
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'creditBalance': _creditBalance, // Update Firestore with new balance
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully redeemed $amount credits!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient credits!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Balance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Credit Balance:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '\$${_creditBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 32, color: Colors.green),
            ),
            SizedBox(height: 40),
            Text(
              'Redeem Credits:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _redeemCredits(10.0), // Example redemption
              child: Text('Redeem \$10'),
            ),
            ElevatedButton(
              onPressed: () => _redeemCredits(20.0), // Example redemption
              child: Text('Redeem \$20'),
            ),
            // Add more redeem options as needed
          ],
        ),
      ),
    );
  }
}
