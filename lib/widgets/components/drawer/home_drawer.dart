import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/service/sos/sos_coordinator.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/widgets/avatar.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/profile/page/profile_page.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  void _onUserLogout() async {
    final isSOSRunning = SosCoordinator().getWaitingFlag();
    if (isSOSRunning) {
      context.pop(); // close drawer
      await Future.delayed(Duration(milliseconds: 300));
      if (!mounted) return;
      AppDialog.error(
        c: context,
        title: "SOS Sedang Berjalan",
        message:
            "Anda tidak bisa keluar dari aplikasi ketika SOS sedang berjalan, tunggu hingga hitung mundur selesai baru Anda bisa keluar.",
        buildActions: (c) => [
          DialogActionButton(label: "Mengerti", primary: true, onTap: c.pop),
        ],
      );
      return;
    }

    await AppDialog.show(
      c: context,
      content: DialogContent(
        assetIcon: "assets/images/logout-icon.png",
        title: "Permintaan Keluar",
        message: "Apakah kamu yakin ingin keluar dari Marlinda?",
        // dc => dialog context
        buildActions: (dc) {
          return [
            DialogActionButton(label: "Batal", onTap: dc.pop),
            DialogActionButton(
              label: "Keluar",
              primary: true,
              onTap: () async {
                dc.pop(); // close dialog dc = dialog context

                final navigator = Navigator.of(context);
                final auth = context.read<AuthProvider>();

                AppDialog.showLoading(context);

                await auth.logout(context);
                if (!mounted) return;

                AppDialog.dismissLoading();

                await Future.delayed(Duration(milliseconds: 300));

                if (mounted) context.pop(); // close drawer

                await Future.delayed(Duration(milliseconds: 300));

                navigator.pushNamedAndRemoveUntil(
                  RoutesNavigation.welcomePage,
                  (route) => false,
                  arguments: {"from_logout": true},
                );
              },
            ),
          ];
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFC82927),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<UserProvider>(
                  builder: (context, p, child) {
                    if (p.getUserState == RequestState.error) {
                      return const SizedBox();
                    }
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: ColorResources.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Avatar(
                                src: p.user?.avatar ?? "",
                                initial: p.user?.username ?? "",
                              ),

                              const SizedBox(width: 15.0),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Nama",
                                    style: robotoRegular.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: ColorResources.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 2.0),

                                  SizedBox(
                                    width: 150.0,
                                    child: Text(
                                      p.user?.username ?? "-",
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        fontWeight: FontWeight.bold,
                                        color: ColorResources.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 15.0),

                          CustomButton(
                            onTap: () {
                              StorageHelper.saveRecordScreen(isHome: false);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const ProfilePage();
                                  },
                                ),
                              );
                            },
                            isBorder: true,
                            isBorderRadius: true,
                            height: 40.0,
                            sizeBorderRadius: 8.0,
                            btnBorderColor: ColorResources.greyDarkPrimary,
                            btnColor: ColorResources.white,
                            btnTxt: "Profile",
                            btnTextColor: const Color(0xFFC82927),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            Bounce(
              onTap: _onUserLogout,
              child: Image.asset(logoutTitle, width: 110.0, height: 110.0),
            ),
          ],
        ),
      ),
    );
  }
}
