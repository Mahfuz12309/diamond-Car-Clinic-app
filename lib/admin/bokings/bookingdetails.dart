import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;

  BookingDetailsPage({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('bookings').doc(bookingId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching booking details.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Booking not found.'));
          }

          var booking = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking ID: ${bookingId}', style: TextStyle(fontSize: 22)),
                SizedBox(height: 10),
                Text('Name: ${booking['name']}', style: TextStyle(fontSize: 18)),
                Text('Car Registration: ${booking['carRegistrationNumber']}', style: TextStyle(fontSize: 18)),
                Text('Address: ${booking['address']}', style: TextStyle(fontSize: 18)),
                Text('Booking Date: ${booking['bookingDate']}', style: TextStyle(fontSize: 18)),
                Text('Booking Time: ${booking['bookingTime']}', style: TextStyle(fontSize: 18)),
                Text('Description: ${booking['description']}', style: TextStyle(fontSize: 18)),
                Text('Problem: ${booking['problem']}', style: TextStyle(fontSize: 18)),
                Text('Status: ${booking['status']}', style: TextStyle(fontSize: 18, color: Colors.green)),
                SizedBox(height: 10),
                Text('Email: ${booking['email']}', style: TextStyle(fontSize: 16)),
                Text('Phone Number: ${booking['phoneNumber']}', style: TextStyle(fontSize: 16)),
                // Optionally display the photo if needed
                if (booking['photo'] != null)
                  Column(
                    children: [
                      Text('Photo:', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Image.network(
                        booking['photo'],
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity, // You can adjust this as necessary
                        errorBuilder: (context, error, stackTrace) {
                          return Text('Failed to load image', style: TextStyle(color: Colors.red));
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}