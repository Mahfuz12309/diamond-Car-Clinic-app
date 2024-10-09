import 'package:diamond_car_clinic/admin/bokings/bookingdetails.dart';
import 'package:diamond_car_clinic/admin/car%20update/provide_update.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingBookingsPage extends StatefulWidget {
  @override
  _PendingBookingsPageState createState() => _PendingBookingsPageState();
}

class _PendingBookingsPageState extends State<PendingBookingsPage> {
  late Future<List<QueryDocumentSnapshot>> pendingBookingsFuture;
  List<QueryDocumentSnapshot> pendingBookings = [];

  @override
  void initState() {
    super.initState();
    pendingBookingsFuture = fetchPendingBookings();
  }

  Future<List<QueryDocumentSnapshot>> fetchPendingBookings() async {
    // Fetch all pending and accepted bookings from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', whereIn: ['Accepted', 'Pending']) // Fetch only accepted or pending bookings
        .get();
    return querySnapshot.docs;
  }

  // Group bookings by user name and car registration number
  Map<String, List<QueryDocumentSnapshot>> groupBookingsByUserAndCar(
      List<QueryDocumentSnapshot> bookings) {
    Map<String, List<QueryDocumentSnapshot>> groupedBookings = {};

    for (var booking in bookings) {
      String userKey =
          '${booking['name']} (${booking['carRegistrationNumber']})';

      if (!groupedBookings.containsKey(userKey)) {
        groupedBookings[userKey] = [];
      }

      groupedBookings[userKey]!.add(booking);
    }

    return groupedBookings;
  }

  void _showConfirmationDialog(String bookingId, String status, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Update'),
          content: Text('You are about to update the status to "$status". Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close confirmation dialog
                await _updateBookingStatus(bookingId, status, index); // Update booking status
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String status, int index) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to "$status".')));
      
      if (status == 'Complete') {
        setState(() {
          pendingBookings.removeAt(index); // Remove the completed booking from the list
        });
      }

    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Bookings'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: pendingBookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending bookings found.'));
          }

          // Store fetched bookings
          pendingBookings = snapshot.data!;

          // Group bookings by user name and car registration number
          var groupedBookings = groupBookingsByUserAndCar(pendingBookings);

          return ListView(
            children: groupedBookings.keys.map((userKey) {
              var userBookings = groupedBookings[userKey]!;

              return ExpansionTile(
                title: Text(userKey), // Displays "User Name (Car Reg Number)"
                children: userBookings.map((booking) {
                  int index = userBookings.indexOf(booking); // Get the index of the booking
                  return ListTile(
                    title: Text(booking['problem']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booking Date: ${booking['bookingDate']}'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to BookingDetailsPage when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingDetailsPage(bookingId: booking.id),
                              ),
                            );
                          },
                          child: Text('View Details'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Add functionality to update the car or proceed with the booking
                            // Navigate to UpdateProvidingPage when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdateProvidingPage(bookingId: booking.id),
                              ),
                            );
                          },
                          child: Text('Update Car'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Update button color
                          ),
                        ),
                        // Buttons to update status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showConfirmationDialog(booking.id, 'Complete', index), // Mark as Complete
                              child: Text('Mark as Complete'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            ElevatedButton(
                              onPressed: () => _showConfirmationDialog(booking.id, 'Pending', index), // Mark as Pending
                              child: Text('Mark as Pending'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
