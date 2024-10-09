import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/admin/user%20management/user_detail_page.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String searchQuery = ''; // Variable to hold the search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Update the search query
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isAdmin', isEqualTo: false) // Exclude admin users
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          // Filter users based on the search query
          final users = snapshot.data!.docs.where((user) {
            return user['name']
                .toString()
                .toLowerCase()
                .contains(searchQuery); // Filter based on search query
          }).toList();

          if (users.isEmpty) {
            return Center(child: Text('No matching users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final bool verified = user['verified'] ?? false;

              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Verify/Unverify Button
                    ElevatedButton(
                      onPressed: () {
                        // Toggle the isVerified field in Firestore
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.id)
                            .update({'verified': !verified});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verified ? Colors.red : Colors.green,
                      ),
                      child: Text(verified ? 'Unverify' : 'Verify'),
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to user details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(userId: user.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
