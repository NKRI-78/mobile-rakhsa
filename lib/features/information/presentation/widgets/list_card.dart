import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

class ListCardInformation extends StatelessWidget {
  const ListCardInformation({super.key, required this.image, required this.title, required this.onTap});

  final String image;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(9)
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  image,
                  width: 50,
                  height: 50,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: ColorResources.black,
                    fontSize: Dimensions.fontSizeExtraLarge,
                    fontWeight: FontWeight.w600
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 30,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}