import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_car_clinic/models/promotion.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({Key? key}) : super(key: key);

  // Fetch promotions that are visible to users and not expired
  Future<List<Promotion>> _fetchActivePromotions() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('promotions')
        .where('isVisible', isEqualTo: true) // Only show visible promotions
        .where('expiryTime', isGreaterThan: Timestamp.now()) // Only show promotions that haven't expired
        .get();

    return snapshot.docs.map((doc) => Promotion.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promotions'),
      ),
      body: FutureBuilder<List<Promotion>>(
        future: _fetchActivePromotions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No active promotions at the moment.'));
          }

          var promotions = snapshot.data!;

          return ListView.builder(
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              var promotion = promotions[index];
              PageController pageController = PageController();

              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promotion title and expiry date above the images
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promotion.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Expires on: ${promotion.expiryTime.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image carousel with page indicator dots
                    Stack(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: promotion.bannerUrls.length,
                            itemBuilder: (context, photoIndex) {
                              return Image.network(
                                promotion.bannerUrls[photoIndex],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Text('Image not available'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        // Dots indicator
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: pageController,
                              count: promotion.bannerUrls.length,
                              effect: ExpandingDotsEffect(
                                activeDotColor: Colors.blue,
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 3,
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
