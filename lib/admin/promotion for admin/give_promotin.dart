import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/models/promotion.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AdminPromotionPage extends StatefulWidget {
  @override
  _AdminPromotionPageState createState() => _AdminPromotionPageState();
}

class _AdminPromotionPageState extends State<AdminPromotionPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedExpiryDate;
  List<File> _selectedBannerImages = [];
  bool _isUploading = false;

  // Function to upload multiple banner images to Firebase Storage
  Future<List<String>> _uploadBannerImages() async {
    List<String> bannerUrls = [];
    for (var image in _selectedBannerImages) {
      String fileName = 'banners/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      bannerUrls.add(downloadUrl);
    }
    return bannerUrls;
  }

  // Function to create a new promotion
  Future<void> _createPromotion() async {
    if (_titleController.text.isEmpty ||
        _selectedExpiryDate == null ||
        _selectedBannerImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Please fill all the fields and select at least one image")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<String> bannerUrls = await _uploadBannerImages();

      Promotion newPromotion = Promotion(
        id: 'newId', // This will be replaced after saving to Firestore
        title: _titleController.text,
        bannerUrls: bannerUrls,
        expiryTime: _selectedExpiryDate!,
        isVisible: true, // Promotion is visible until expired
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('promotions')
          .add(newPromotion.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Promotion created successfully")),
      );
      _titleController.clear();
      _selectedBannerImages = [];
      _selectedExpiryDate = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create promotion")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Pick multiple images using image picker
  Future<void> _pickBannerImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedBannerImages =
            pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Select the expiry date
  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin - Promotions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Promotion Title"),
            ),
            SizedBox(height: 16),
            Text("Banner Images:"),
            SizedBox(height: 8),
            _selectedBannerImages.isNotEmpty
                ? CarouselSlider(
                    items: _selectedBannerImages.map((image) {
                      return Image.file(image, height: 150);
                    }).toList(),
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                    ),
                  )
                : Text("No images selected"),
            TextButton(
              onPressed: _pickBannerImages,
              child: Text("Select Banner Images"),
            ),
            SizedBox(height: 16),
            Text("Expiry Date:"),
            SizedBox(height: 8),
            Text(
              _selectedExpiryDate == null
                  ? "No date selected"
                  : _selectedExpiryDate!.toLocal().toString().split(' ')[0],
            ),
            TextButton(
              onPressed: () => _selectExpiryDate(context),
              child: Text("Select Expiry Date"),
            ),
            SizedBox(height: 16),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createPromotion,
                    child: Text("Create Promotion"),
                  ),
            SizedBox(height: 24),
            Expanded(
              child: _PromotionsList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionsList extends StatelessWidget {
  Future<void> _deletePromotion(BuildContext context, String promotionId) async {
    bool confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this promotion?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      await FirebaseFirestore.instance.collection('promotions').doc(promotionId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Promotion deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('promotions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final promotions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: promotions.length,
          itemBuilder: (context, index) {
            var promotion = promotions[index];
            var data = promotion.data() as Map<String, dynamic>;
            bool isExpired = data['expiryTime'].toDate().isBefore(DateTime.now());

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the CarouselSlider for images
                  if (data['bannerUrls'] != null && data['bannerUrls'].isNotEmpty)
                    Container(
                      height: 150, // Set a fixed height for images
                      child: CarouselSlider(
                        items: (data['bannerUrls'] as List<dynamic>).map((url) {
                          return Image.network(url, fit: BoxFit.cover);
                        }).toList(),
                        options: CarouselOptions(
                          height: 150,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: true,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.8,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the promotion title
                        Text(
                          data['title'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        // Display the expiry date
                        Text(
                          isExpired
                              ? "Expired"
                              : "Expires on: ${data['expiryTime'].toDate().toLocal().toString().split(' ')[0]}",
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _deletePromotion(context, promotion.id),
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
