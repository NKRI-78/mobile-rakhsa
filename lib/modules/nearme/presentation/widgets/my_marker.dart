import 'package:flutter/material.dart';

class TextOnImage extends StatelessWidget {
  const TextOnImage({super.key, required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          image: AssetImage("assets/images/icons/$icon"),
          height: 50.0,
          width: 50.0,
        ),
      ],
    );
  }
}
