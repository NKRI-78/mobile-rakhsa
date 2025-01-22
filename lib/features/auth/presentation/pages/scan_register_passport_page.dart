import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/features/auth/presentation/widget/scanning_effect.dart';

class ScanRegisterPassportPage extends StatefulWidget {
  const ScanRegisterPassportPage({super.key});

  @override
  State<ScanRegisterPassportPage> createState() => _ScanRegisterPassportPageState();
}

class _ScanRegisterPassportPageState extends State<ScanRegisterPassportPage> {
  @override
  void initState() {
    super.initState();
    // redirect to document scanner
    if (!context.read<RegisterNotifier>().hasPath) {
      context.read<RegisterNotifier>().startScan(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + kToolbarHeight + 16;

    return PopScope(
      onPopInvoked: (_) => context.read<RegisterNotifier>().deleteData(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: top,
          backgroundColor: primaryColor,
          automaticallyImplyLeading: false,
          flexibleSpace: Image.asset(
            AssetSource.loginOrnament,
            fit: BoxFit.cover,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // passpor view
              Expanded(
                child: Material(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  child: Consumer<RegisterNotifier>(
                    builder: (context, provider, child) {
                      if (provider.hasPath) {
                        return ScanningEffect(
                          endScan: provider.hasPassport,
                          child: Image.file(
                            File(provider.passportPath),
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Memulai Pemindaian Paspor',
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(color: redColor),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // button face recognition
              Consumer<RegisterNotifier>(
                builder: (context, provider, child) {
                  if (provider.hasPath) {
                    return ElevatedButton(
                      onPressed: provider.hasPassport 
                      ? () {
                         Navigator.pushNamed(context, RoutesNavigation.registerFr,arguments: provider.passport);
                        } 
                      : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: whiteColor,
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Lanjut Untuk Pemindaian Wajah'),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
