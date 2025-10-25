import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

class ListCardInformation extends StatelessWidget {
  const ListCardInformation({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
  });

  final String image;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(image, width: 45.0, height: 45.0),
      title: Text(
        title,
        style: const TextStyle(
          color: ColorResources.black,
          fontSize: Dimensions.fontSizeExtraLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward, size: 30.0),
      onTap: onTap,
      tileColor: whiteColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
    );
  }
}
