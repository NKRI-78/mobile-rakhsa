import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/widgets/avatar.dart';

import 'package:rakhsa/widgets/components/button/bounce.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/profile/page/profile_page.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class DrawerWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const DrawerWidget({required this.globalKey, super.key});

  @override
  State<DrawerWidget> createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
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

            Bouncing(
              child: Image.asset(logoutTitle, width: 110.0, height: 110.0),
              onPress: () async {
                bool? logout = await AppDialog.show(
                  c: context,
                  content: DialogContent(
                    assetIcon: "assets/images/logout-icon.png",
                    title: "Permintaan Keluar",
                    message: "Apakah kamu yakin ingin keluar dari Marlinda?",
                    actions: [
                      DialogActionButton(
                        label: "Batal",
                        onTap: () => context.pop(false),
                      ),
                      DialogActionButton(
                        label: "Keluar",
                        primary: true,
                        onTap: () => context.pop(true),
                      ),
                    ],
                  ),
                );
                if (logout != null && logout) {
                  log("mounted? before logout ${context.mounted}");
                  // ignore: use_build_context_synchronously
                  await locator<AuthProvider>().logout();
                  widget.globalKey.currentState?.closeDrawer();
                  log("mounted? after logout ${context.mounted}");
                  Navigator.pushNamedAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    RoutesNavigation.welcomePage,
                    (route) => false,
                  );
                } else {
                  Future.delayed(Duration(milliseconds: 300)).then((value) {
                    // ignore: use_build_context_synchronously
                    context.pop();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
