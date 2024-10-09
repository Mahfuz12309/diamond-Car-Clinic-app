import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendNotificationScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController notificationController = TextEditingController();

  Future<void> sendNotification(String userId, String message) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'message': message,
      'timestamp': Timestamp.now(),
    });

    // Use Firebase Cloud Messaging (FCM) to send a notification
    // Additional FCM setup required for real-time notifications
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['email']),
                subtitle: TextField(
                  controller: notificationController,
                  decoration: InputDecoration(labelText: 'Notification Message'),
                ),
                trailing: ElevatedButton(
                  onPressed: () => sendNotification(user.id, notificationController.text),
                  child: Text('Send'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
