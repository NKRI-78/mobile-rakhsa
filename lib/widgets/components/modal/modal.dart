import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/routes/nav_key.dart';

import 'package:rakhsa/routes/routes_navigation.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/sos_rating_notifier.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/socketio.dart';

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

                              Navigator.pop(context);
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

  static Future<void> ratingSos({required String sosId, required bool isHome}) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 320.0,
                  height: 380.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 20.0,
                        right: 20.0,
                        bottom: 20.0,
                        child: Container(
                          height: 150.0,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: "Di ",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Marlinda",
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFC82927),
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ",\nkami sangat menghargai kesetiaan\ndan dukungan Anda sebagai pengguna\nkami yang terhormat",
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: ColorResources.black,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 15.0),

                              RatingBar.builder(
                                initialRating: 0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 25.0,
                                itemPadding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                itemBuilder: (BuildContext context, int i) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                onRatingUpdate: (double selectedRating) {
                                  context
                                      .read<SosRatingNotifier>()
                                      .onChangeRating(
                                        selectedRating: selectedRating,
                                      );

                                  context.read<SosRatingNotifier>().sosRating(
                                    sosId: sosId,
                                  );

                                  context
                                      .read<SocketIoService>()
                                      .userResolvedSos(sosId: sosId);

                                  Navigator.pop(context);

                                  if (!isHome) {
                                    Navigator.pushNamed(
                                      context,
                                      RoutesNavigation.dashboard,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
