import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeHightlightBanner extends StatefulWidget {
  const HomeHightlightBanner(this.banners, {super.key});

  final List<Widget> banners;

  @override
  State<HomeHightlightBanner> createState() => _HomeHightlightBannerState();
}

class _HomeHightlightBannerState extends State<HomeHightlightBanner> {
  int _currentBannerIndex = 0;

  void _onBannerIndexChanged(int index) {
    if (mounted) {
      _currentBannerIndex = index;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannersLength = widget.banners.length;
    return ClipRRect(
      borderRadius: .circular(16),
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 190,
              autoPlay: true,
              pageSnapping: true,
              viewportFraction: 1,
              autoPlayInterval: Duration(seconds: 9),
              enableInfiniteScroll: bannersLength > 1,
              onPageChanged: (index, realIndex) {
                _onBannerIndexChanged(index);
              },
            ),
            items: widget.banners,
          ),

          if (bannersLength > 1)
            Positioned(
              right: 12,
              left: 12,
              bottom: 12,
              child: Row(
                spacing: 6,
                mainAxisAlignment: .center,
                children: List.generate(bannersLength, (index) {
                  final active = index == _currentBannerIndex;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white60,
                      borderRadius: .circular(100),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
