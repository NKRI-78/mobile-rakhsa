import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  
  late RegisterNotifier registerNotifier;

  bool isDialogShowing = false; 

  Future<void> requestAllPermissions() async {
    if (isDialogShowing) return; // Prevent re-entry
    isDialogShowing = true;

    debugPrint("=== REQUESTING PERMISSIONS ===");

    if (await requestPermission(Permission.location, "location", "location.png")) return;

    if (!await Geolocator.isLocationServiceEnabled()) {
      await showDialog("Perizinan akses device lokasi dibutuhkan, silahkan aktifkan terlebih dahulu", "GPS", "location.png");
      isDialogShowing = false;
      return;
    }
    
    if (await requestPermission(Permission.notification, "notification", "notification.png")) return;
    if (await requestPermission(Permission.microphone, "microphone", "microphone.png")) return;
    if (await requestPermission(Permission.camera, "camera", "camera.png")) return;

    debugPrint("ALL PERMISSIONS GRANTED");
    isDialogShowing = false;

    if(!mounted) return;
      await registerNotifier.registerWithGoogle(context);
  }

  Future<bool> requestPermission(Permission permission, String type, String img) async {
    var status = await permission.request();

    if(type == "notification") {
      if (status ==  PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
        await showDialog("Perizinan akses $type dibutuhkan, silahkan aktifkan terlebih dahulu", type, img);
        isDialogShowing = false;
        return true;
      }
    } else {
      if (status == PermissionStatus.permanentlyDenied) {
        await showDialog("Perizinan akses $type dibutuhkan, silahkan aktifkan terlebih dahulu", type, img);
        isDialogShowing = false;
        return true;
      }

      if (status != PermissionStatus.granted) {
        debugPrint("Permission $type denied, stopping process.");
        isDialogShowing = false;
        return true; 
      }
    }
 
    return false; 
  }

  Future<void> showDialog(String message, String type, String img) async {
    if (!isDialogShowing) return;
    await GeneralModal.dialogRequestPermission(
      msg: message, 
      type: type, 
      img: img
    );
  }

  Future<void> onUserAction() async {
    if(Platform.isAndroid) {
      requestAllPermissions();
    } else {
      if(!mounted) return;
        await registerNotifier.registerWithGoogle(context);
    }
  }

  @override 
  void initState() {
    super.initState();

    registerNotifier = context.read<RegisterNotifier>();

    Future.microtask(() async {
      if (await Geolocator.checkPermission() == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      await [
        Permission.camera,
        Permission.microphone,
        Permission.notification,
      ].request();
    });
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: primaryColor,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // pattern fadding
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(AssetSource.loginOrnament),
            ),

            // content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // logo
                  Image.asset(AssetSource.logoMarlinda,
                    width: 90.0,
                    fit: BoxFit.scaleDown,
                  ),

                  // title 'marlinda'
                  Text(
                    '\n"Mari Lindungi Diri Anda"\n',
                    textAlign: TextAlign.center,
                    style: gilroyRegular.copyWith(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeExtraLarge,
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // login button
                  ElevatedButton(
                    onPressed: () async {
                      if(Platform.isIOS) {
                        Dio dio = Dio();
                        Response res = await dio.get("https://api-rakhsa.inovatiftujuh8.com/api/v1/admin/toggle/feature");
                        if(res.data["data"]["feature_fr_login"] == true) {
                          Navigator.pushNamed(context, RoutesNavigation.loginFr);
                        } else {
                          Navigator.pushNamed(context, RoutesNavigation.login);
                        }
                      } else {
                        Navigator.pushNamed(context, RoutesNavigation.loginFr);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: whiteColor,
                      backgroundColor: primaryColor,
                      side: const BorderSide(color: whiteColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Divider(color: whiteColor.withOpacity(0.5)),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Atau',
                            style: robotoRegular.copyWith(
                              color: whiteColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Divider(color: whiteColor.withOpacity(0.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // register button
                  Consumer<RegisterNotifier>(
                    builder: (context, provider, child) {
                    return OutlinedButton(
                      onPressed: () async {
                        await onUserAction();
                      }, 
                      style: ElevatedButton.styleFrom(
                        foregroundColor: blackColor,
                        backgroundColor: whiteColor,
                        side: const BorderSide(color: whiteColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: (provider.ssoLoading)
                        ? const Center(
                            child: SpinKitFadingCircle(
                              color: blackColor, 
                              size: 25.0
                            ),
                          )
                        : Text('Registrasi',
                            style: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ),
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
