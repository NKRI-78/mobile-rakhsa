import 'package:badges/badges.dart' as badges;

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/service/socket/socketio.dart';
import 'package:rakhsa/widgets/avatar.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        // profile, title, & logo marlinda
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            // profile
            Flexible(
              child: GestureDetector(
                onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                child: Consumer<UserProvider>(
                  builder: (context, provider, child) {
                    return Avatar(
                      src: provider.user?.avatar ?? "",
                      initial: provider.user?.username ?? "",
                    );
                  },
                ),
              ),
            ),

            // title marlinda
            Flexible(
              fit: .tight,
              child: Image.asset(Assets.titleMarlinda, height: 38.0),
            ),

            // logo marlinda
            Flexible(
              child: Image.asset(
                Assets.logoMarlindaNoTitle,
                width: 45,
                height: 45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // welcome, connection indicator, & notif
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            // text selamat datang
            Flexible(
              fit: .tight,
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 14, color: Color(0xff9E9E9E)),
                  ),
                  Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      if (provider.getUserState == .success) {
                        return SizedBox(
                          width: 150.0,
                          child: Text(
                            provider.user?.username ?? "-",
                            overflow: .ellipsis,
                            style: TextStyle(fontWeight: .bold, fontSize: 14),
                          ),
                        );
                      } else {
                        return const Text('-');
                      }
                    },
                  ),
                ],
              ),
            ),

            Consumer<SocketIoService>(
              builder: (context, n, child) {
                return Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: n.connStatus.color,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),

            // icon notif
            InkWell(
              onTap: () => NotificationRoute().go(context),
              borderRadius: .circular(8),
              child: Material(
                child: Consumer<UserProvider>(
                  builder: (context, n, child) {
                    return badges.Badge(
                      showBadge: n.user?.sos?.running ?? false,
                      position: badges.BadgePosition.custom(top: -8, end: -4),
                      badgeContent: Text(
                        "0",
                        style: TextStyle(color: primaryColor, fontSize: 9),
                      ),
                      child: const Icon(
                        IconsaxPlusLinear.notification,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
