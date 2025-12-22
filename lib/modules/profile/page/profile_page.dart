import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/modules/referral/widget/referral_info_container.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';
import 'package:rakhsa/widgets/avatar.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchUser(enableCache: true);
    });
  }

  Future<void> _fetchUser({bool enableCache = false}) async {
    await context.read<UserProvider>().getUser(enableCache: enableCache);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Colors.grey);
    final valueStyle = TextStyle(color: Colors.black, fontWeight: .w600);

    final top = context.top + kToolbarHeight;

    return StatusBarStyle.light(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        body: RefreshIndicator.adaptive(
          onRefresh: () async =>
              await _fetchUser(enableCache: BuildConfig.isStag),
          color: primaryColor,
          child: Consumer<UserProvider>(
            builder: (context, notifier, child) {
              final packages = notifier.user?.package ?? [];
              return ListView(
                padding: .zero,
                children: [
                  // avatar
                  Container(
                    padding: .fromLTRB(16, top, 16, (top - 16)),
                    alignment: .center,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.75),
                          primaryColor,
                        ],
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/images/login-ornament.png"),
                        fit: .cover,
                      ),
                    ),
                    child: Bounce(
                      onTap: () => HapticService.instance.lightImpact(),
                      child: Avatar(
                        src: notifier.user?.avatar,
                        radius: 53,
                        initial: notifier.user?.username,
                        withBorder: true,
                      ),
                    ),
                  ),

                  // info profil
                  Padding(
                    padding: .fromLTRB(16, 16, 16, context.bottom + 16),
                    child: Column(
                      spacing: 16,
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text("Nama", style: labelStyle),
                            Text(
                              notifier.user?.username ?? "-",
                              style: valueStyle,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text("Nomor Telepon", style: labelStyle),
                            Text(
                              notifier.user?.contact ?? "-",
                              style: valueStyle,
                            ),
                          ],
                        ),

                        if (BuildConfig.isProd && packages.isNotEmpty)
                          Padding(
                            padding: .only(top: 16),
                            child: Column(
                              spacing: 16,
                              mainAxisSize: .min,
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  "Informasi Layanan Marlinda",
                                  style: TextStyle(fontWeight: .w600),
                                ),
                                ReferralInfoContainer(package: packages[0]),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
