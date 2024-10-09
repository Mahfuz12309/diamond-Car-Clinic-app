import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _selectedImage;
  String userEmail = ''; // To store the user's email

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        nameController.text = userDoc['name'] ?? '';
        registrationController.text = userDoc['carRegNumber'] ?? '';
        phoneController.text = userDoc['phoneNumber'] ?? '';
        addressController.text = userDoc['address'] ?? '';
        userEmail = user.email ?? ''; // Automatically capture the logged-in user's email
      }
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      // Create a reference to Firebase Storage
      String filePath = 'uploads/${Uuid().v4()}.jpg'; // Create a unique file path
      var ref = FirebaseStorage.instance.ref().child(filePath);
      await ref.putFile(image); // Upload the image
      String downloadUrl = await ref.getDownloadURL(); // Get the download URL
      return downloadUrl; // Return the download URL
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      // Upload image and get the URL
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToFirebase(_selectedImage!);
      }

      // Create a booking record to store in Firestore
      var bookingData = {
        'name': nameController.text,
        'carRegistrationNumber': registrationController.text,
        'phoneNumber': phoneController.text,
        'address': addressController.text,
        'bookingDate': dateController.text,
        'bookingTime': timeController.text,
        'problem': problemController.text,
        'description': descriptionController.text,
        'photo': imageUrl, // Save the image URL
        'email': userEmail, // Store the logged-in user's email
        'id': Uuid().v4(), // Unique ID for the booking
      };

      try {
        // Store booking data in Firestore
        await FirebaseFirestore.instance.collection('bookings').add(bookingData);
        _showSuccessDialog();
      } catch (e) {
        log('Error submitting booking: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Successful'),
          content: Text('Your booking has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to homepage
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book Your Appointment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  _buildEditableField('Name:', nameController),
                  _buildEditableField('Car Registration Number:', registrationController),
                  _buildEditableField('Phone Number:', phoneController),
                  _buildEditableField('Address:', addressController),
                  _buildEditableField('Problem:', problemController),
                  _buildEditableField('Description:', descriptionController),

                  SizedBox(height: 20),
                  _buildDateTimeField('Booking Date:', dateController, context),
                  _buildDateTimeField('Booking Time:', timeController, context),

                  SizedBox(height: 20),
                  Text('Upload Photo:', style: TextStyle(fontSize: 18)),
                  ElevatedButton(
                    onPressed: _selectImage,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Select Photo'),
                  ),
                  SizedBox(height: 10),
                  _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(),

                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Submit Booking', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18)),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.all(10),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDateTimeField(String label, TextEditingController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18)),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            if (label == 'Booking Date:') {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format date
              }
            } else {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                controller.text = pickedTime.format(context);
              }
            }
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please select a booking ${label.toLowerCase()}';
            }
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.all(10),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
