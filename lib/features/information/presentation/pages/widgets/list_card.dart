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
      height: 85.0,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(9.0)
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        borderRadius: BorderRadius.circular(9.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(9.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      
                      Image.asset(
                        image,
                        width: 45.0,
                        height: 45.0,
                      ),
                      
                      const SizedBox(width: 15.0),
                            
                      Text(
                        title,
                        style: const TextStyle(
                          color: ColorResources.black,
                          fontSize: Dimensions.fontSizeExtraLarge,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                            
                    ]
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 30.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}