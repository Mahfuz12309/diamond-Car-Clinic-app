import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/customer/edit_profile.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Details'),
          backgroundColor: Colors.cyan,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_userData!['name'] ?? 'User'} Details'),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to the edit profile page when the edit button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userId: widget.userId, // Pass the userId to the edit screen
                    userData: _userData!, // Pass the user data to the edit screen
                  ),
                ),
              ).then((_) {
                // Fetch the latest user details after returning from the edit page
                _getUserDetails();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(_userData!['customerPhotoUrl'] ?? 'assets/user_photo.png'), // User photo
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person, color: Colors.cyan),
              title: Text('Name'),
              subtitle: Text(_userData!['name'] ?? 'No Name'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.cyan),
              title: Text('Email'),
              subtitle: Text(_userData!['email'] ?? 'No Email'),
            ),
            ListTile(
              leading: Icon(Icons.directions_car, color: Colors.cyan),
              title: Text('Car Registration Number'),
              subtitle: Text(_userData!['carRegNumber'] ?? 'No Car Reg. Number'),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.cyan),
              title: Text('Address'),
              subtitle: Text(_userData!['address'] ?? 'No Address'),
            ),
            ListTile(
              leading: Icon(Icons.photo, color: Colors.cyan),
              title: Text('Car Photo'),
              subtitle: _userData!['carPhotoUrl'] != null
                  ? Image.network(_userData!['carPhotoUrl'])
                  : Text('No Car Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
