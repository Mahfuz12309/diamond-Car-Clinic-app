import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/customer/booking.dart';
import 'package:diamond_car_clinic/models/service.dart';
import 'package:flutter/material.dart';

class Service {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add service (booking) data
  Future<void> addService(ServiceModel serviceData) async {
    try {
      await _firestore.collection('services').doc(serviceData.id).set(serviceData.toMap());
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }
}

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<ServiceModel> services = []; // List to hold fetched services

  @override
  void initState() {
    super.initState();
    _fetchServices(); // Fetch services on initialization
  }

  // Fetch services from Firestore
  Future<void> _fetchServices() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('services').get();
      setState(() {
        services = snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error fetching services: $e'); // Handle errors appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
        backgroundColor: Colors.cyan[700],
      ),
      body: services.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                ServiceModel service = services[index];
                return ListTile(
                  title: Text(service.name),
                  subtitle: Text('${service.bookingDate} - ${service.bookingTime}'),
                  onTap: () {
                    // Navigate to the booking form with the selected service data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
