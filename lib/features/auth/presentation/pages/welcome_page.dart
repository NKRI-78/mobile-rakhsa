import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
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
                  Image.asset(AssetSource.logoMarlinda),

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
                  const SizedBox(height: 100),

                  // login button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RoutesNavigation.loginFr);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: blackColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Divider(color: whiteColor.withOpacity(0.5)),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Atau',
                            style: TextStyle(
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
                  const SizedBox(height: 24),

                  // register button
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RoutesNavigation.scanRegisterPassport,
                    ),
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: whiteColor),
                      foregroundColor: whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Registrasi'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
