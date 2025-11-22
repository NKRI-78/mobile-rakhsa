import 'package:flutter/material.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:upgrader/upgrader.dart';

class AppUpgradeAlert extends UpgradeAlert {
  AppUpgradeAlert({super.key, super.upgrader, super.child, super.navigatorKey});

  @override
  UpgradeAlertState createState() => AppUpgradeAlertState();
}

class AppUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    AppDialog.show(
      c: widget.navigatorKey?.currentState?.overlay?.context ?? context,
      canPop: false,
      dismissible: false,
      content: DialogContent(
        assetIcon: AssetSource.iconWelcomeDialog,
        title: "Pembaruan Tersedia",
        message:
            "Versi terbaru aplikasi tersedia. Disarankan untuk memperbarui agar mendapatkan perbaikan dan fitur baru.",
        actionButtonDirection: Axis.vertical,
        style: DialogStyle(assetIconSize: 130),
        buildActions: (c) {
          return [
            DialogActionButton(
              label: "Ingatkan nanti",
              onTap: () => onUserLater(c, true),
            ),
            DialogActionButton(
              label: "Perbarui sekarang",
              primary: true,
              onTap: () => onUserUpdated(c, !widget.upgrader.blocked()),
            ),
          ];
        },
      ),
    );
  }
}
