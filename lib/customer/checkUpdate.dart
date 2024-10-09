import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diamond_car_clinic/customer/update_detail.dart';

class CheckUpdatePage extends StatefulWidget {
  @override
  _CheckUpdatePageState createState() => _CheckUpdatePageState();
}

class _CheckUpdatePageState extends State<CheckUpdatePage> {
  List<QueryDocumentSnapshot> pendingBookings = [];
  String? currentUserEmail; // Store current user email

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserEmail(); // Fetch the current user's email on page load
  }

  // Fetch the current user's email
  Future<void> _fetchCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserEmail = user.email; // Get current user email
      await _fetchPendingBookings(); // Fetch pending bookings after getting the email
    }
  }

  // Fetch pending bookings for the current user
  Future<void> _fetchPendingBookings() async {
    if (currentUserEmail == null) return;

    // Fetch only pending bookings from Firestore where the user's email matches
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('email', isEqualTo: currentUserEmail) // Filter by user email
        .where('status', isEqualTo: 'Pending') // Filter by pending status
        .get();

    setState(() {
      pendingBookings = snapshot.docs; // Store the fetched pending bookings
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Bookings'),
      ),
      body: pendingBookings.isEmpty
          ? Center(child: Text('No pending bookings found.'))
          : ListView.builder(
              itemCount: pendingBookings.length,
              itemBuilder: (context, index) {
                var bookingData = pendingBookings[index].data() as Map<String, dynamic>;
                var email = bookingData['email'] ?? 'No email specified'; // Get the email
                var problem = bookingData['problem'] ?? 'No problem specified'; // Get the problem
                var bookingId = pendingBookings[index].id; // Get the booking ID

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      '$email - $problem', // Display both email and problem
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Navigate to the update details page for this booking
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateDetailsPage(bookingId: bookingId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
