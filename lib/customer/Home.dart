import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/customer/Promotion.dart';
import 'package:diamond_car_clinic/customer/booking.dart';
import 'package:diamond_car_clinic/customer/chat.dart';
import 'package:diamond_car_clinic/customer/checkUpdate.dart';
import 'package:diamond_car_clinic/customer/credit.dart';
import 'package:diamond_car_clinic/customer/profile.dart';
import 'package:diamond_car_clinic/customer/serviceHistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diamond_car_clinic/authencation/login.dart';
import 'package:diamond_car_clinic/models/service.dart'; // Import your ServiceModel

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _fullName;
  bool _isAdmin = false; // Flag to determine if the user is an admin
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserFullName();
    _checkAdminStatus();
  }

  Future<void> _getUserFullName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _fullName = userDoc['name'] ?? 'User';
        });
      }
    }
  }

  // Check if the user is an admin
  Future<void> _checkAdminStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc['isAdmin'] == true) {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }

  // Fetch initial service data
  Future<ServiceModel?> _fetchInitialServiceData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('services').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return ServiceModel.fromFirestore(snapshot.docs[0]);
      }
    } catch (e) {
      print('Error fetching service data: $e');
    }
    return null; // Return null if no data found or an error occurs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.cyan[700],
            automaticallyImplyLeading: false,
            expandedHeight: 60.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20, height: 20),
                  Image.asset('assets/logo.png', height: 40), // Logo in AppBar
                  SizedBox(width: 8),
                  Text(
                    'Diamond Car Clinic',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Profile and Welcome Text Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, ${_fullName ?? 'Loading...'}!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showProfileOptions(context); // Open profile options
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/user_photo.png'),
                        ),
                      ),
                    ],
                  ),
                  // Main functionality - Grid of buttons
                  Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.1, // Adjust opacity for watermark effect
                          child: Image.asset('assets/logo.png'), // Your watermark logo
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(), // Disable scrolling
                        children: [
                          CustomButton(
                            label: 'Check Updates',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckUpdatePage(),
                                ),
                              );
                            },
                          ),
                          CustomButton(
                            label: 'Book Service',
                            onTap: () async {
                              
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingPage(),
                                  ),
                                );
                              
                            },
                          ),
                          CustomButton(
                            label: 'Service History',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ServiceHistoryPage()),
                              );
                            },
                          ),
                          CustomButton(
                            label: 'Promotions',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PromotionPage()),
                              );
                            },
                          ),
       
                          CustomButton(
                            label: 'Manage Credit',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreditPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Profile options with admin dashboard and profile viewing/editing
  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: Colors.cyan),
                  title: Text('View Profile'),
                  onTap: () {
                    if (userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(userId: userId!), // Pass userId to profile page
                        ),
                      ).then((_) {
                        // Fetch the latest user details after returning from the edit page
                        _getUserFullName();
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.cyan),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.cyan),
                  title: Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
                if (_isAdmin) // Only show admin dashboard if user is admin
                  ListTile(
                    leading: Icon(Icons.admin_panel_settings, color: Colors.cyan),
                    title: Text('Admin Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to admin dashboard
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  CustomButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
