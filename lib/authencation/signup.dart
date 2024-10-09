import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/authencation/waiting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _carRegController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _customerImage;
  File? _carImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isCustomer) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isCustomer) {
          _customerImage = File(pickedFile.path);
        } else {
          _carImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(File image, String folderName) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Register the user using email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Upload the images to Firebase Storage
        String? customerPhotoUrl;
        String? carPhotoUrl;

        if (_customerImage != null) {
          customerPhotoUrl = await _uploadImage(_customerImage!, 'customer_photos');
        }

        if (_carImage != null) {
          carPhotoUrl = await _uploadImage(_carImage!, 'car_photos');
        }

        // Save additional user information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'carRegNumber': _carRegController.text.trim(),
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'customerPhotoUrl': customerPhotoUrl ?? '',
          'carPhotoUrl': carPhotoUrl ?? '',
          'firstTimeUser': true,
          'verified': false, // Initially not verified
          'isAdmin':false,
        });

        // Send the user to the verification or home page after registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WaitingScreen(userId: user.uid)),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Customer Name'),
                    ),
                    TextField(
                      controller: _carRegController,
                      decoration: InputDecoration(labelText: 'Car Registration Number'),
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Address'),
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    Text('Customer Photo:'),
                    SizedBox(height: 10),
                    _customerImage != null
                        ? Image.file(_customerImage!)
                        : Text('No image selected'),
                    ElevatedButton(
                      onPressed: () => _pickImage(true),
                      child: Text('Upload/Take Customer Photo'),
                    ),
                    SizedBox(height: 20),
                    Text('Car Photo:'),
                    SizedBox(height: 10),
                    _carImage != null
                        ? Image.file(_carImage!)
                        : Text('No image selected'),
                    ElevatedButton(
                      onPressed: () => _pickImage(false),
                      child: Text('Upload/Take Car Photo'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
