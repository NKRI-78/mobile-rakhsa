import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/service/sos/sos_coordinator.dart';
import 'package:rakhsa/widgets/avatar.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';

import 'package:rakhsa/widgets/components/custom.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer(this.parentContext, {super.key});

  final BuildContext parentContext;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  void _onUserLogout() async {
    final isSOSRunning = SosCoordinator().getWaitingFlag();
    if (isSOSRunning) {
      context.pop(); // close drawer
      await Future.delayed(Duration(milliseconds: 300));

      if (widget.parentContext.mounted) {
        await AppDialog.error(
          c: widget.parentContext,
          title: "SOS Sedang Berjalan",
          message:
              "Anda tidak bisa keluar dari aplikasi ketika SOS sedang berjalan, tunggu hingga hitung mundur selesai baru Anda bisa keluar.",
          buildActions: (c) => [
            DialogActionButton(label: "Mengerti", primary: true, onTap: c.pop),
          ],
        );
      }
      return;
    }

    context.pop(); // close drawer
    await Future.delayed(Duration(milliseconds: 300));

    if (widget.parentContext.mounted) {
      await AppDialog.show(
        c: widget.parentContext,
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

                  final auth = widget.parentContext.read<AuthProvider>();

                  AppDialog.showLoading(widget.parentContext);

                  await auth.logout(widget.parentContext);

                  AppDialog.dismissLoading();

                  if (widget.parentContext.mounted) {
                    WelcomeRoute().go(widget.parentContext);
                  }
                },
              ),
            ];
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFC82927),
      child: Container(
        padding: const .all(8.0),
        child: Column(
          mainAxisAlignment: .spaceBetween,
          mainAxisSize: .min,
          children: [
            Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Consumer<UserProvider>(
                  builder: (context, p, child) {
                    if (p.getUserState == .error) {
                      return const SizedBox();
                    }
                    return Container(
                      padding: const .all(16.0),
                      decoration: const BoxDecoration(
                        borderRadius: .all(.circular(10.0)),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          Row(
                            mainAxisSize: .min,
                            children: [
                              Avatar(
                                src: p.user?.avatar ?? "",
                                initial: p.user?.username ?? "",
                              ),

                              const SizedBox(width: 15.0),

                              Column(
                                crossAxisAlignment: .start,
                                mainAxisSize: .min,
                                children: [
                                  Text(
                                    "Nama",
                                    style: TextStyle(
                                      fontWeight: .bold,
                                      fontSize: 12,
                                      color: Color(0xff707070),
                                    ),
                                  ),

                                  const SizedBox(height: 2.0),

                                  SizedBox(
                                    width: 150.0,
                                    child: Text(
                                      p.user?.username ?? "-",
                                      overflow: .ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: .bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 15.0),

                          CustomButton(
                            onTap: () => ProfileRoute().go(context),
                            isBorder: true,
                            isBorderRadius: true,
                            height: 40.0,
                            sizeBorderRadius: 8.0,
                            btnBorderColor: Color(0xff707070),
                            btnColor: Colors.white,
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
              child: Image.asset(
                "assets/images/logout.png",
                width: 110.0,
                height: 110.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
