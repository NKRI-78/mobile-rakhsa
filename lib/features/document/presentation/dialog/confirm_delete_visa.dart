import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/features/document/presentation/provider/document_notifier.dart';
import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class ConfirmDeleteVisaDialog extends StatelessWidget {
  const ConfirmDeleteVisaDialog._();

  static Future<void> launch() async {
    await showGeneralDialog(
      context: navigatorKey.currentContext!,
      barrierLabel: '',
      barrierDismissible: true,
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(scale: a1, child: child);
      },
      pageBuilder: (context, a1, a2) {
        return const ConfirmDeleteVisaDialog._();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.only(
              top: 60.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Apakah kamu yakin ingin menghapus visa yang telah kamu daftarkan?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Expanded(child: SizedBox()),
                    Expanded(
                      flex: 5,
                      child: CustomButton(
                          isBorderRadius: true,
                          isBoxShadow: false,
                          btnColor: ColorResources.white,
                          btnTextColor: ColorResources.black,
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              Navigator.pop(context);
                            });
                          },
                          btnTxt: "Batal"),
                    ),
                    const Expanded(child: SizedBox()),
                    Expanded(
                        flex: 5,
                        child: Consumer<DocumentNotifier>(
                            builder: (context, provider, child) {
                          return CustomButton(
                            isBorderRadius: true,
                            isBoxShadow: false,
                            isLoading: provider.visaIsLoading,
                            btnColor: ColorResources.error,
                            btnTextColor: ColorResources.white,
                            onTap: () async {
                              await provider.deleteVisaEvent().then((_) {
                                Navigator.pop(context);
                              });
                            },
                            btnTxt: "Hapus",
                          );
                        })),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -50,
            child: Image.asset(
              AssetSource.iconAlert,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
