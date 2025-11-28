import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/modules/auth/widget/terms_and_conditions_dialog.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/service/permission/permission_manager.dart';

import 'package:rakhsa/widgets/dialog/app_dialog.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with WidgetsBindingObserver {
  bool _openedSettings = false;
  bool _hasPermissionDialogLaunchBefore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && PermissionManager().hasTaskExecutionBefore) {
        _handlePermission();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (!_openedSettings) return;
      if (_hasPermissionDialogLaunchBefore) return;
      _openedSettings = false;
      _hasPermissionDialogLaunchBefore = true;
      await _handlePermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handlePermission() async {
    await PermissionManager().requestAllPermissionsWithHandler(
      parentContext: context,
      onRequestPermanentlyDenied: () {
        _openedSettings = true;
        _hasPermissionDialogLaunchBefore = false;
      },
    );
  }

  Future<void> _showTermsAndConditionDialog(BuildContext c) async {
    if (!c.mounted) return;
    bool? agree = await TermsAndConditionsDialog.launch(c, true);
    if (c.mounted && agree != null && agree) {
      await Future.delayed(Duration(milliseconds: 300));
      if (c.mounted) AppDialog.showLoading(c);
      await Future.delayed(Duration(milliseconds: 500));
      AppDialog.dismissLoading();
      if (c.mounted) await _handlePermission();
    }
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
                        await PermissionManager().resetTaskExecutionFlag();
                        if (context.mounted) LoginRoute().go(context);
                      } else {
                        await _showTermsAndConditionDialog(context);
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
                        await PermissionManager().resetTaskExecutionFlag();
                        if (context.mounted) RegisterRoute().go(context);
                      } else {
                        await _showTermsAndConditionDialog(context);
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
