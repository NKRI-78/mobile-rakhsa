import 'package:badges/badges.dart' as badges;

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/enums/request_state.dart';
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // profile, title, & logo marlinda
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              fit: FlexFit.tight,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // text selamat datang
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 14, color: Color(0xff9E9E9E)),
                  ),
                  Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      if (provider.getUserState == RequestState.success) {
                        return SizedBox(
                          width: 150.0,
                          child: Text(
                            provider.user?.username ?? "-",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
                    shape: BoxShape.circle,
                    color: n.connStatus.color,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),

            // icon notif
            InkWell(
              onTap: () => NotificationRoute().go(context),
              borderRadius: BorderRadius.circular(8),
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
