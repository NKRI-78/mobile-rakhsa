import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/color_resources.dart';

class TextOnImage extends StatelessWidget {
  const TextOnImage({
    super.key,
    required this.text,
  });

  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Image(
          image: AssetImage("assets/icons/mosque.png"),
          height: 130,
          width: 130,
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              color: ColorResources.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        )
      ],
    );
  }
}
