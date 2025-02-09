import 'package:badges/badges.dart' as badges;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/socketio.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.scaffoldKey,
  });

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
                child: Consumer<ProfileNotifier>(
                  builder: (_, provider, __) => CachedNetworkImage(
                    imageUrl: provider.entity.data?.avatar ?? "",
                    imageBuilder: (_, imgProvider) => CircleAvatar(
                      backgroundImage: imgProvider,
                    ),
                    placeholder: (_, __) => const CircleAvatar(
                      backgroundImage: AssetImage(AssetSource.iconNoProfile),
                    ),
                    errorWidget: (_, __, ____) => const CircleAvatar(
                      backgroundImage: AssetImage(AssetSource.iconNoProfile),
                    ),
                  ),
                ),
              ),
            ),

            // title marlinda
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                'MARLINDA',
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                style: robotoRegular.copyWith(
                  color: redColor,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
              ),
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
                      color: ColorResources.hintColor
                    ),
                  ),
                  Consumer<ProfileNotifier>(
                    builder: (context, provider, child) {
                      if (provider.state == ProviderState.loaded) {
                        return SizedBox(
                          width: 150.0,
                          child: Text(
                            provider.entity.data?.username ?? "-",
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

            // connection indicator
            Consumer<SocketIoService>(
              builder: (context, provider, child) {
                return Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.indicatorColor,
                  ),
                );
              }
            ),
            const SizedBox(width: 16),

            // icon notif
            InkWell(
              onTap: () => Navigator.pushNamed(context, RoutesNavigation.chats),
              borderRadius: BorderRadius.circular(8),
              child: Material(
                child: Consumer<GetChatsNotifier>(
                  builder: (context, notifier, child) {
                    return badges.Badge(
                      showBadge: notifier.chats.isNotEmpty,
                      position: badges.BadgePosition.custom(
                        top: -8,
                        end: -4,
                      ),
                      badgeContent: Text(
                        notifier.chats.length.toString(), 
                        style: robotoRegular.copyWith(
                          color: whiteColor,
                          fontSize: 9,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined, 
                        size: 28,
                      ),
                    );
                  }
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
