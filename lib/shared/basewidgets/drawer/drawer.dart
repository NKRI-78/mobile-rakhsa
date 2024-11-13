import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFC82927),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            CustomButton(
              onTap: () {
              
              },
              isBorder: true,
              isBorderRadius: true,
              btnColor: ColorResources.transparent,
              btnBorderColor: ColorResources.white,
              fontSize: Dimensions.fontSizeDefault,
              btnTxt: "Notification",
            ),

            Image.asset(logoutTitle,
              width: 110.0,
              height: 110.0,
            )

          ],
        ),
      ),
    );
  }
}