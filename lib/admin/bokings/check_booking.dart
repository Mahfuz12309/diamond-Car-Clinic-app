import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bookingdetails.dart'; // Import your BookingDetailsPage

class CheckBookingsPage extends StatefulWidget {
  @override
  _CheckBookingsPageState createState() => _CheckBookingsPageState();
}

class _CheckBookingsPageState extends State<CheckBookingsPage> {
  late Future<List<QueryDocumentSnapshot>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = fetchBookings();
  }

  Future<List<QueryDocumentSnapshot>> fetchBookings() async {
    // Fetch all bookings from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('bookings').get();

    // Filter bookings that do not contain the 'status' field
    List<QueryDocumentSnapshot> bookings = querySnapshot.docs.where((booking) {
      // Cast booking data to a Map<String, dynamic>
      var data = booking.data() as Map<String, dynamic>?; // Cast the data

      // Check if booking data is not null and does not contain 'status'
      return data != null && !data.containsKey('status');
    }).toList();

    return bookings;
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

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      // Update the status of the booking
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }

  void _removeBookingFromList(String bookingId) {
    setState(() {
      bookingsFuture = bookingsFuture.then((bookings) {
        bookings.removeWhere((booking) => booking.id == bookingId);
        return bookings;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Bookings'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings found.'));
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
                        Text('Booking Date: ${booking['bookingDate']}'),
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
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await _updateBookingStatus(booking.id, 'Accepted');
                                    _removeBookingFromList(booking.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Booking accepted')),
                                    );
                                  },
                                  child: Text('Accept'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, // Accept button color
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _updateBookingStatus(booking.id, 'Rejected');
                                    _removeBookingFromList(booking.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Booking rejected')),
                                    );
                                  },
                                  child: Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // Reject button color
                                  ),
                                ),
                              ],
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
