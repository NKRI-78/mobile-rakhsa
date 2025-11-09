import 'package:bounce/bounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/helpers/vibration_manager.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/widgets/avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (mounted) {
        context.read<UserProvider>().getUser(enableCache: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Colors.grey);
    final valueStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: context.pop,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Consumer<UserProvider>(
          builder: (context, notifier, child) {
            return Column(
              children: [
                Container(
                  height: 300,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.75),
                        primaryColor,
                      ],
                    ),
                    image: DecorationImage(
                      image: AssetImage("assets/images/login-ornament.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Bounce(
                    onTap: () =>
                        locator<VibrationManager>().vibrate(durationInMs: 50),
                    child: Avatar(
                      src: notifier.user?.avatar,
                      radius: 53,
                      initial: notifier.user?.username,
                      withBorder: true,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Nama", style: labelStyle),
                          Text(
                            notifier.user?.username ?? "-",
                            style: valueStyle,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Nomor Telepon", style: labelStyle),
                          Text(
                            notifier.user?.contact ?? "-",
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
