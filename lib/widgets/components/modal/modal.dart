import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/router/router.dart';

import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';

class GeneralModal {
  static Future<void> dialogRequestPermission({
    required String msg,
    required String type,
    required String img,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 290.0,
                    height: 280.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                          child: Container(
                            height: 200.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg,
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          top: 0.0,
                          left: 80.0,
                          right: 80.0,
                          child: Image.asset(
                            "assets/images/icons/$img",
                            height: 100.0,
                          ),
                        ),

                        Positioned(
                          bottom: 40.0,
                          left: 80.0,
                          right: 80.0,
                          child: CustomButton(
                            isBorder: false,
                            btnColor: blueColor,
                            btnTextColor: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                            sizeBorderRadius: 8.0,
                            isBorderRadius: true,
                            height: 30.0,
                            onTap: () async {
                              // if(type == "notification") {
                              //   await AppSettings.openAppSettings(type: AppSettingsType.notification);
                              // }
                              if (type == "location") {
                                openAppSettings();
                              }
                              // if(type == "GPS") {
                              //   await AppSettings.openAppSettings(type: AppSettingsType.location);
                              // }
                              if (type == "camera") {
                                openAppSettings();
                              }
                              if (type == "microphone") {
                                openAppSettings();
                              }

                              context.pop();
                            },
                            btnTxt: "Izinkan",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
