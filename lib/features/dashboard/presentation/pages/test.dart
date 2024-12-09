
import 'dart:async';

import 'package:flutter/material.dart';

class HorizontalAutoScroll extends StatefulWidget {
  const HorizontalAutoScroll({super.key});

  @override
  State<HorizontalAutoScroll> createState() => _HorizontalAutoScrollState();
}

class _HorizontalAutoScrollState extends State<HorizontalAutoScroll> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  final double _scrollStep = 2.0; // The amount to scroll each tick

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll < maxScroll) {
          _scrollController.animateTo(
            currentScroll + _scrollStep,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        } else {
          _scrollController.jumpTo(0); // Reset to the start
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150, // Fixed height for horizontal ListView
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue[(index % 9 + 1) * 100],
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.center,
            child: Text(
              'Item $index',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}