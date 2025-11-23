import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/modules/auth/widget/terms_and_conditions_dialog.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';

import 'package:rakhsa/widgets/components/modal/modal.dart';
import 'package:rakhsa/widgets/dialog/app_dialog.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  bool isDialogShowing = false;

  Future<void> requestAllPermissions() async {
    if (isDialogShowing) return; // Prevent re-entry
    isDialogShowing = true;

    debugPrint("=== REQUESTING PERMISSIONS ===");

    if (await requestPermission(
      Permission.location,
      "location",
      "location.png",
    )) {
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      await showDialog(
        "Perizinan akses device lokasi dibutuhkan, silahkan aktifkan terlebih dahulu",
        "GPS",
        "location.png",
      );
      isDialogShowing = false;
      return;
    }

    if (await requestPermission(
      Permission.notification,
      "notification",
      "notification.png",
    )) {
      return;
    }
    if (await requestPermission(
      Permission.microphone,
      "microphone",
      "microphone.png",
    )) {
      return;
    }
    if (await requestPermission(Permission.camera, "camera", "camera.png")) {
      return;
    }

    debugPrint("ALL PERMISSIONS GRANTED");
    isDialogShowing = false;
  }

  Future<bool> requestPermission(
    Permission permission,
    String type,
    String img,
  ) async {
    var status = await permission.request();

    if (type == "notification") {
      if (status == PermissionStatus.denied ||
          status == PermissionStatus.permanentlyDenied) {
        await showDialog(
          "Perizinan akses $type dibutuhkan, silahkan aktifkan terlebih dahulu",
          type,
          img,
        );
        isDialogShowing = false;
        return true;
      }
    } else {
      if (status == PermissionStatus.permanentlyDenied) {
        await showDialog(
          "Perizinan akses $type dibutuhkan, silahkan aktifkan terlebih dahulu",
          type,
          img,
        );
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
      img: img,
    );
  }

  Future<void> _showTermsAndConditionDialog() async {
    if (!mounted) return;
    bool? agree = await TermsAndConditionsDialog.launch(context, true);
    if (mounted && agree != null && agree) {
      await Future.delayed(Duration(milliseconds: 300));
      // ignore: use_build_context_synchronously
      AppDialog.showLoading(context);
      await Future.delayed(Duration(milliseconds: 600));
      AppDialog.dismissLoading();
      await _requestAllPermissions();
    }
  }

  Future<Map<Permission, PermissionStatus>> _requestAllPermissions() {
    return [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.location,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
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
                  Image.asset(
                    AssetSource.logoMarlinda,
                    width: 90.0,
                    fit: BoxFit.scaleDown,
                  ),

                  // title 'marlinda'
                  Text(
                    '\n"Mari Lindungi Diri Anda"\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeExtraLarge,
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // login button
                  ElevatedButton(
                    onPressed: () async {
                      if (TermsAndConditionsDialog.hasLaunchBefore) {
                        Navigator.pushNamed(context, RoutesNavigation.login);
                      } else {
                        await _showTermsAndConditionDialog();
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
                        child: Divider(
                          color: whiteColor.withValues(alpha: 0.5),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Atau',
                            style: robotoRegular.copyWith(
                              color: whiteColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Divider(
                          color: whiteColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // register button
                  OutlinedButton(
                    onPressed: () async {
                      if (TermsAndConditionsDialog.hasLaunchBefore) {
                        Navigator.pushNamed(context, RoutesNavigation.register);
                      } else {
                        await _showTermsAndConditionDialog();
                      }
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
                      child: Text(
                        'Registrasi',
                        style: robotoRegular.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
  }
}
