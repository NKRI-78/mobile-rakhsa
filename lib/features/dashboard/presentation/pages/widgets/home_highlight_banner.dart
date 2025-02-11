import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeHightlightBanner extends StatelessWidget {
  const HomeHightlightBanner({
    super.key,
    required this.banners,
  });

  final List<Widget> banners;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 190,
          autoPlay: true,
          pageSnapping: true,
          viewportFraction: 1,
          autoPlayInterval: const Duration(seconds: 9),
          scrollPhysics: const BouncingScrollPhysics(),
        ),
        items: banners,
      ),
    );
  }
}