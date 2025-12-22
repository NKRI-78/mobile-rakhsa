import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/service/sos/sos_coordinator.dart';
import 'package:rakhsa/widgets/avatar.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/widgets/components/app_button.dart';

import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

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
          assetIcon: Assets.imagesDialogLogout,
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
    final topPadding = context.top + 16;
    final bottomPadding = context.bottom + 16;
    return StatusBarStyle.light(
      child: Drawer(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: .zero),
        child: Container(
          padding: .fromLTRB(16, topPadding, 16, bottomPadding),
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisAlignment: .spaceBetween,
            children: [
              Consumer<UserProvider>(
                builder: (context, p, child) {
                  if (p.getUserState != .success) return SizedBox();
                  return Container(
                    padding: .all(16),
                    decoration: BoxDecoration(
                      borderRadius: .circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      spacing: 16,
                      mainAxisSize: .min,
                      crossAxisAlignment: .stretch,
                      children: [
                        Row(
                          spacing: 16,
                          children: [
                            Avatar(
                              src: p.user?.avatar ?? "",
                              initial: p.user?.username ?? "",
                            ),

                            Expanded(
                              child: Column(
                                spacing: 2,
                                mainAxisSize: .min,
                                crossAxisAlignment: .stretch,
                                children: [
                                  Text(
                                    p.user?.username ?? "-",
                                    overflow: .ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                  Text(
                                    p.user?.contact ?? "-",
                                    overflow: .ellipsis,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        AppButton(
                          label: "Profile",
                          icon: Icons.person,
                          type: .outlined,
                          onPressed: () => ProfileRoute().go(context),
                        ),
                      ],
                    ),
                  );
                },
              ),

              AppButton(
                label: "Logout",
                icon: Icons.logout,
                style: AppButtonStyle(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                ),
                onPressed: _onUserLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
