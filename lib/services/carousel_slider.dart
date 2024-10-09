import 'dart:io';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  ImageCarousel({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: imageUrls.map((url) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(
              File(url), // Use File to get image from the file path
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
    );
  }
}
