import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  EditProfileScreen({required this.userId, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _carRegController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _carRegController = TextEditingController(text: widget.userData['carRegNumber']);
    _addressController = TextEditingController(text: widget.userData['address']);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': _nameController.text,
        'carRegNumber': _carRegController.text,
        'address': _addressController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully'),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Car Registration Field
              TextFormField(
                controller: _carRegController,
                decoration: InputDecoration(labelText: 'Car Registration Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a car registration number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
