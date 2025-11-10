import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_version_plus/new_version_plus.dart';

import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';

class UpdateAppPage extends StatefulWidget {
  const UpdateAppPage({super.key});

  @override
  State<UpdateAppPage> createState() => UpdateAppPageState();
}

class UpdateAppPageState extends State<UpdateAppPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        child: Scaffold(
          backgroundColor: ColorResources.backgroundColor,
          body: SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        AssetSource.update,
                        width: 250.0,
                        height: 250.0,
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "NEW VERSION AVAILABLE",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.w600,
                              color: ColorResources.black,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          if (Platform.isAndroid)
                            Text(
                              "Versi terbaru Raksha tersedia di Google Play Store",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: ColorResources.black,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomButton(
                    onTap: () async {
                      final newVersion = NewVersionPlus(
                        androidId: 'com.inovatiftujuh8.rakhsa',
                        // iOSId: 'com.inovatif78.fspmi'
                      );
                      if (Platform.isAndroid) {
                        newVersion.launchAppStore(
                          "https://play.google.com/store/apps/details?id=com.inovatiftujuh8.rakhsa",
                        );
                      }
                    },
                    isBorderRadius: false,
                    isBorder: false,
                    isBoxShadow: false,
                    btnColor: const Color(0xFFFE1717),
                    btnTxt: "Update",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
