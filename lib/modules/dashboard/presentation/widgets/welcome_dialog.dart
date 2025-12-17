import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeDialog extends StatelessWidget {
  const WelcomeDialog._();

  static void launch(BuildContext c) {
    AppDialog.show(
      c: c,
      dismissible: false,
      customDialogBuilder: (dc) => WelcomeDialog._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(color: Colors.black87, fontSize: 13);
    final infoStyle = defaultStyle.copyWith(
      fontSize: 11.5,
      color: Colors.black54,
    );
    return DialogCard(
      DialogContent(
        assetIcon: AssetSource.iconWelcomeDialog,
        title: "Terimakasih ${StorageHelper.session?.user.name ?? "-"}",
        messageWidget: Consumer<UserProvider>(
          builder: (context, p, child) {
            final packages = p.user?.package ?? [];
            final days = packages.isNotEmpty
                ? packages.first.extractNumberFromKeyword()
                : 0;
            return Text.rich(
              maxLines: 8,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              TextSpan(
                text: "Pembelian paket layanan Marlinda ",
                style: defaultStyle,
                children: [
                  TextSpan(
                    text: "$days hari",
                    style: defaultStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text:
                        " berhasil. Akses Marlinda Anda akan tetap aktif mengikuti masa aktif terpanjang untuk layanan Marlinda di nomor ini.\n\n",
                    style: defaultStyle,
                  ),
                  TextSpan(
                    text: "Untuk informasi lebih lanjut, hubungi call center ",
                    style: infoStyle,
                  ),
                  TextSpan(
                    text: "+6281119911911",
                    style: infoStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final uri = Uri(scheme: 'tel', path: "+6281119911911");
                        AppDialog.showLoading(context);
                        if (await canLaunchUrl(uri)) {
                          try {
                            await launchUrl(uri);
                          } finally {
                            AppDialog.dismissLoading();
                          }
                        }
                      },
                  ),
                  TextSpan(text: " atau melalui ", style: infoStyle),
                  TextSpan(
                    text: "https://marlinda.id/",
                    style: infoStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final uri = Uri.parse("https://marlinda.id/");
                        AppDialog.showLoading(context);
                        if (await canLaunchUrl(uri)) {
                          try {
                            await launchUrl(uri);
                          } finally {
                            AppDialog.dismissLoading();
                          }
                        }
                      },
                  ),
                ],
              ),
            );
          },
        ),
        style: DialogStyle(assetIconSize: 175),
        actionButtonDirection: Axis.vertical,
        buildActions: (dc) => [
          DialogActionButton(
            label: "Oke",
            primary: true,
            onTap: () => dc.pop(true),
          ),
        ],
      ),
    );
  }
}
