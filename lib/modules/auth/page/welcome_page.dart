import 'package:flutter/material.dart';

import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/modules/auth/widget/terms_and_conditions_dialog.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/service/permission/permission_manager.dart';

import 'package:rakhsa/widgets/dialog/app_dialog.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

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
    return StatusBarStyle.light(
      child: Scaffold(
        backgroundColor: primaryColor,
        body: SizedBox(
          width: double.infinity,
          height: context.getScreenHeight(),
          child: Stack(
            children: [
              // pattern fadding
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(Assets.loginOrnament),
              ),

              // content
              Padding(
                padding: const .all(16),
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .stretch,
                  children: [
                    // logo
                    Image.asset(
                      Assets.logoMarlinda,
                      width: 90.0,
                      fit: .scaleDown,
                    ),

                    // title 'marlinda'
                    Text(
                      '\n"Mari Lindungi Diri Anda"\n',
                      textAlign: .center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: .bold,
                        fontSize: 18,
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
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(12),
                        ),
                      ),
                      child: const Padding(
                        padding: .all(12.0),
                        child: Text('Login'),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // divider
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        Flexible(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const .symmetric(horizontal: 16.0),
                            child: Text(
                              'Atau',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.5),
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
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const .all(12),
                        child: Text(
                          'Registrasi',
                          style: TextStyle(fontWeight: .bold),
                        ),
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
  }
}
