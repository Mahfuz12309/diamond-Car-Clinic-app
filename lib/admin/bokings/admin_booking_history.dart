import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bookingdetails.dart'; // Import your BookingDetailsPage

class AdminServiceHistoryPage extends StatefulWidget {
  @override
  _AdminServiceHistoryPageState createState() => _AdminServiceHistoryPageState();
}

class _AdminServiceHistoryPageState extends State<AdminServiceHistoryPage> {
  late Future<List<QueryDocumentSnapshot>> completedBookingsFuture;

  @override
  void initState() {
    super.initState();
    completedBookingsFuture = fetchCompletedBookings();
  }

  Future<List<QueryDocumentSnapshot>> fetchCompletedBookings() async {
    // Fetch all completed bookings from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'Complete') // Fetch only completed services
        .get();
    return querySnapshot.docs;
  }

  // Group bookings by user name and car registration number
  Map<String, List<QueryDocumentSnapshot>> groupBookingsByUserAndCar(List<QueryDocumentSnapshot> bookings) {
    Map<String, List<QueryDocumentSnapshot>> groupedBookings = {};

    for (var booking in bookings) {
      String userKey = '${booking['name']} (${booking['carRegistrationNumber']})';

      if (!groupedBookings.containsKey(userKey)) {
        groupedBookings[userKey] = [];
      }

      groupedBookings[userKey]!.add(booking);
    }

    return groupedBookings;
  }

  Future<void> _revertBookingStatus(String bookingId) async {
    try {
      // Update the status of the booking back to "Pending"
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'Pending',
      });
    } catch (e) {
      print('Error reverting booking status: $e');
    }
  }

  void _removeBookingFromList(String bookingId) {
    setState(() {
      completedBookingsFuture = completedBookingsFuture.then((bookings) {
        bookings.removeWhere((booking) => booking.id == bookingId);
        return bookings;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Service History'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: completedBookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No completed services.'));
          }

          // Group bookings by user name and car registration number
          var groupedBookings = groupBookingsByUserAndCar(snapshot.data!);

          return ListView(
            children: groupedBookings.keys.map((userKey) {
              var userBookings = groupedBookings[userKey]!;

              return ExpansionTile(
                title: Text(userKey), // Displays "User Name (Car Reg Number)"
                children: userBookings.map((booking) {
                  return ListTile(
                    title: Text(booking['problem']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Completed on: ${booking['bookingDate']}'),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to BookingDetailsPage when tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailsPage(bookingId: booking.id),
                                  ),
                                );
                              },
                              child: Text('View Details'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _revertBookingStatus(booking.id);
                                _removeBookingFromList(booking.id); // Remove the booking from the list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Booking status reverted to Pending')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Button to revert status
                              ),
                              child: Text('Revert to Pending'),
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
