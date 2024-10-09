import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateDetailsPage extends StatelessWidget {
  final String bookingId;

  UpdateDetailsPage({required this.bookingId});

  Future<List<QueryDocumentSnapshot>> _fetchBookingUpdates() async {
    // Fetch all updates corresponding to the bookingId, sorted by timestamp in descending order
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('updates')
        .where('bookingId', isEqualTo: bookingId)
        .orderBy('timestamp', descending: true) // Sort by time, newest first
        .get();

    return snapshot.docs; // Return the list of updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Update Details'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchBookingUpdates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If no updates are found or the booking ID is not correct
            return Center(child: Text('No updates found for this booking.'));
          }

          var updates = snapshot.data!;

          return ListView.builder(
            itemCount: updates.length,
            itemBuilder: (context, index) {
              var updateData = updates[index].data() as Map<String, dynamic>;
              
              // Use null-aware operators to safely extract data
              var message = updateData['message'] ?? 'No message provided';
              var estimatedDate = updateData['estimatedDate']?.toDate();
              var timestamp = updateData['timestamp']?.toDate();
              var photos = updateData['photos'] as List<dynamic>? ?? [];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Debugging: Display the booking ID
                        Text(
                          'Booking ID: $bookingId',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        // Debugging: Ensure timestamp and other data are displayed correctly
                        Text(
                          'Update at: ${timestamp?.toLocal().toString() ?? 'No Timestamp Available'}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Message: $message', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Estimated Date: ${estimatedDate?.toLocal().toString() ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 16),
                        photos.isEmpty
                            ? Text('No photos available.')
                            : SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: photos.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Image.network(
                                        photos[index],
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
