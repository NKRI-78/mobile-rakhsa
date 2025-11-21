import 'package:badges/badges.dart' as badges;

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';
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
              child: Image.asset(AssetSource.titleMarlinda, height: 38.0),
            ),

            // logo marlinda
            Flexible(
              child: Image.asset(
                AssetSource.logoMarlindaNoTitle,
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
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: ColorResources.hintColor,
                    ),
                  ),
                  Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      if (provider.getUserState == RequestState.success) {
                        return SizedBox(
                          width: 150.0,
                          child: Text(
                            provider.user?.username ?? "-",
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.fontSizeDefault,
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
              onTap: () => Navigator.pushNamed(context, RoutesNavigation.chats),
              borderRadius: BorderRadius.circular(8),
              child: Material(
                child: Consumer<UserProvider>(
                  builder: (context, n, child) {
                    return badges.Badge(
                      showBadge: n.user?.sos?.running ?? false,
                      position: badges.BadgePosition.custom(top: -8, end: -4),
                      badgeContent: Text(
                        "0",
                        style: robotoRegular.copyWith(
                          color: primaryColor,
                          fontSize: 9,
                        ),
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
