import 'package:diamond_car_clinic/customer/Home.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  final Function? onComplete; // Accept onComplete as a parameter

  OnboardingScreen({this.onComplete}); // Constructor

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Welcome to App",
      "body": "This is a simple onboarding screen example.",
      "image": "assets/welcome.png"
    },
    {
      "title": "Discover Features",
      "body": "Explore the various features of the app.",
      "image": "assets/discover.png"
    },
    {
      "title": "Get Started",
      "body": "Let's get you started with our app!",
      "image": "assets/get_started.png"
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If the user reaches the last page, call the onComplete callback
      if (widget.onComplete != null) {
        widget.onComplete!(); // Call the onComplete function
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        _onboardingData[index]["image"]!,
                        height: 250,
                      ),
                      SizedBox(height: 20),
                      Text(
                        _onboardingData[index]["title"]!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _onboardingData[index]["body"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: _onboardingData.length,
            effect: WormEffect(
              dotHeight: 12,
              dotWidth: 12,
              spacing: 16,
              activeDotColor: Colors.blue,
              dotColor: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: _onNextPage,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentPage == _onboardingData.length - 1
                    ? "Get Started"
                    : "Next",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
