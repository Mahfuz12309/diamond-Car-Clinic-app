import 'package:diamond_car_clinic/admin/bokings/admin_booking_history.dart';
import 'package:diamond_car_clinic/admin/bokings/check_booking.dart';
import 'package:diamond_car_clinic/admin/car%20update/available_cars.dart';
import 'package:diamond_car_clinic/admin/promotion%20for%20admin/give_promotin.dart';
import 'package:diamond_car_clinic/admin/user%20management/user_management.dart';
import 'package:diamond_car_clinic/authencation/login.dart';
import 'package:diamond_car_clinic/admin/send_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication

class AdminDashboard extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false, // This will remove the back button
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Add a logout icon
            onPressed: () async {
              await _auth.signOut(); // Sign out from Firebase
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to login page
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          AdminDashboardButton(
            title: ' Users',
            icon: Icons.verified_user,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserManagementPage()));
            },
          ),
          AdminDashboardButton(
            title: ' Provide update',
            icon: Icons.verified_user,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PendingBookingsPage ()));
            },
          ),
          AdminDashboardButton(
            title: ' Promotion',
            icon: Icons.verified_user,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPromotionPage ()));
            },
          ),
          AdminDashboardButton(
            title: 'service History',
            icon: Icons.car_repair,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AdminServiceHistoryPage()),);
            },
          ),
          AdminDashboardButton(
            title: 'Send Notifications',
            icon: Icons.notifications,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SendNotificationScreen()));
            },
          ),
          // AdminDashboardButton(
          //   title: 'Give Promotion',
          //   icon: Icons.delete,
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteCarScre));
          //   },
          // ),
          AdminDashboardButton(
            title: 'Check bookings',
            icon: Icons.book_online,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckBookingsPage()));
            },
          ),

        ],
      ),
    );
  }
}

class AdminDashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  AdminDashboardButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: TextStyle(fontSize: 18)),
        onTap: onPressed,
      ),
    );
  }
}
