import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/chat/presentation/pages/chats.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class DrawerWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const DrawerWidget({
    required this.globalKey,
    super.key
  });

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
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return const ChatsPage();
                }));
              },
              isBorder: true,
              isBorderRadius: true,
              btnColor: ColorResources.transparent,
              btnBorderColor: ColorResources.white,
              fontSize: Dimensions.fontSizeDefault,
              btnTxt: "Notification",
            ),

            Bouncing(
              child: Image.asset(logoutTitle,
                width: 110.0,
                height: 110.0,
              ), 
              onPress: () async {
                await GeneralModal.logout(globalKey: widget.globalKey);
              }
            )
            

          ],
        ),
      ),
    );
  }
}