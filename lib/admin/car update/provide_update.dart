import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:diamond_car_clinic/models/car_update_model.dart';

class UpdateProvidingPage extends StatefulWidget {
  final String bookingId; // ID of the booking related to this update

  UpdateProvidingPage({required this.bookingId});

  @override
  _UpdateProvidingPageState createState() => _UpdateProvidingPageState();
}

class _UpdateProvidingPageState extends State<UpdateProvidingPage> {
  final TextEditingController _messageController = TextEditingController();
  DateTime? _estimatedDate;
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  String currentStatus = 'Loading...'; // Default status
  String? customerEmail; // To store customer email

  @override
  void initState() {
    super.initState();
    _fetchCurrentStatus();
  }

  // Fetch current status and customer email from bookings
  void _fetchCurrentStatus() async {
    try {
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingSnapshot.exists) {
        setState(() {
          currentStatus = bookingSnapshot['status'] ?? 'Unknown';
          customerEmail = bookingSnapshot['email'] ?? 'customer@example.com'; // Fetch email
        });
      }
    } catch (e) {
      print('Error fetching booking status: $e');
      setState(() {
        currentStatus = 'Error loading status';
      });
    }
  }

  // Select images from gallery
  void _selectImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _images = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  // Upload images to Firebase Storage and get URLs
  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (File image in _images) {
      String fileName = Uuid().v4(); // Unique file name
      Reference storageRef = FirebaseStorage.instance.ref().child('updates/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  // Save the update to Firestore
  Future<void> _saveUpdate() async {
    if (_estimatedDate == null || _messageController.text.isEmpty || customerEmail == null) return;

    try {
      // Upload images first
      List<String> uploadedImageUrls = await _uploadImages();

      // Create an UpdateModel instance
      final updateModel = UpdateModel(
        id: '', // Firestore will assign the ID
        bookingId: widget.bookingId,
        message: _messageController.text,
        estimatedDate: Timestamp.fromDate(_estimatedDate!),
        timestamp: Timestamp.now(),
        customerEmail: customerEmail!, // Use the fetched customer email
        photos: uploadedImageUrls, // Store uploaded image URLs
      );

      // Save to Firestore
      await FirebaseFirestore.instance.collection('updates').add(updateModel.toMap());

      // Clear fields after saving
      _messageController.clear();
      setState(() {
        _estimatedDate = null;
        _images.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update saved successfully.')));
    } catch (e) {
      print('Error saving update: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save update.')));
    }
  }

  void _showConfirmationDialog(String status) {
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
                await _updateBookingStatus(status); // Update booking status
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

  Future<void> _updateBookingStatus(String status) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to "$status".')));
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Providing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status: $currentStatus', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showConfirmationDialog('Complete'), // Mark as Complete
                  child: Text('Mark as Complete'),
                ),
                ElevatedButton(
                  onPressed: () => _showConfirmationDialog('Pending'), // Mark as Pending
                  child: Text('Mark as Pending'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Message:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Estimated Delivery Date:', style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _estimatedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                );

                setState(() {
                  _estimatedDate = selectedDate;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_estimatedDate == null
                    ? 'Select a date'
                    : 'Estimated Date: ${_estimatedDate!.toLocal()}'.split(' ')[0]),
              ),
            ),
            SizedBox(height: 16),
            Text('Upload Images:', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: _selectImages,
              child: Text('Select Images'),
            ),
            SizedBox(height: 16),
            _images.isNotEmpty
                ? Wrap(
                    children: _images.map((image) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                      );
                    }).toList(),
                  )
                : Container(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_estimatedDate != null && _messageController.text.isNotEmpty) {
                  _saveUpdate(); // Save the update
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.')));
                }
              },
              child: Text('Save Update'),
            ),
          ],
        ),
      ),
    );
  }
}
