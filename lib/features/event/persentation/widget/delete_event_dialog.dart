
import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class DeleteEventDialog extends StatelessWidget {
  const DeleteEventDialog(this.event, {super.key});

  final EventData event;

  static Future<T?> launch<T>(BuildContext context, EventData event) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteEventDialog(event),
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
                  'Hapus Agenda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apakah anda yaking ingin menghapus ${event.title}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 5,
                      child: CustomButton(
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.grey,
                        btnTextColor: ColorResources.white,
                        onTap: () => Navigator.of(context).pop(false),
                        btnTxt: 'Batal',
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CustomButton(
                          isBorderRadius: true,
                          isBoxShadow: false,
                          btnColor: ColorResources.error,
                          btnTextColor: ColorResources.white,
                          onTap: () => Navigator.of(context).pop(true),
                          btnTxt: "Hapus",
                        ),
                      ),
                    ), 
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