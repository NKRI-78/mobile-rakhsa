import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/repositories/nearme/model/google_maps_place.dart';

enum MapsLaunchMode { goToMaps, openOnGoogleMaps, openOnAppleMaps }

class MapsLaunchModeDialog extends StatelessWidget {
  const MapsLaunchModeDialog._(this.place, this.fromMapsTile);

  final GoogleMapsPlace place;
  final bool fromMapsTile;

  static Future<MapsLaunchMode?> launch(
    BuildContext context,
    GoogleMapsPlace place, {
    bool fromMapsTile = false,
  }) {
    return showModalBottomSheet<MapsLaunchMode?>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(16)),
      ),
      builder: (dialogContext) {
        return MapsLaunchModeDialog._(place, fromMapsTile);
      },
    );
  }

  @override
  Widget build(BuildContext dialogContext) {
    final bottomBasedOS = Platform.isIOS ? 8.0 : 24.0;
    final bottomPadding = dialogContext.bottom + bottomBasedOS;
    final tileShape = RoundedRectangleBorder(borderRadius: .circular(12));

    final dm = place.distanceInMeters;
    final dkm = dm / 1000;
    final distanceLabel = dm.toInt() < 1000
        ? "${dm.toInt()} meter"
        : "${dkm.toStringAsFixed(2)} kilometer";

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: .fromLTRB(16, 0, 16, bottomPadding),
        child: Column(
          spacing: 6,
          mainAxisSize: .min,
          children: [
            Text(
              place.placeName,
              maxLines: 3,
              textAlign: .center,
              overflow: .ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: .bold),
            ),
            if (place.vicinity != null)
              Text(
                place.vicinity!,
                maxLines: 4,
                textAlign: .center,
                overflow: .ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            Text(
              "$distanceLabel dari lokasi Anda",
              textAlign: .center,
              overflow: .ellipsis,
              style: TextStyle(fontSize: 12),
            ),

            16.spaceY,

            if (!fromMapsTile)
              ListTile(
                leading: Image.asset(
                  Assets.imagesNearmeMapsLocalMaps,
                  width: 32,
                  height: 32,
                ),
                title: Text("Maps"),
                subtitle: Text("Lihat lokasi di Maps"),
                trailing: Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.black54,
                ),
                onTap: () {
                  dialogContext.pop(MapsLaunchMode.goToMaps);
                },
                shape: tileShape,
              ),
            if (Platform.isIOS)
              ListTile(
                leading: Image.asset(
                  Assets.imagesNearmeMapsAppleMaps,
                  width: 32,
                  height: 32,
                ),
                title: Text("Apple Maps"),
                subtitle: Text("Buka menggunakan Apple Maps"),
                trailing: Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.black54,
                ),
                onTap: () {
                  dialogContext.pop(MapsLaunchMode.openOnAppleMaps);
                },
                shape: tileShape,
              ),
            ListTile(
              leading: Image.asset(
                Assets.imagesNearmeMapsGoogleMaps,
                width: 32,
                height: 32,
              ),
              title: Text("Google Maps"),
              subtitle: Text("Buka menggunakan Google Maps"),
              trailing: Icon(
                Icons.arrow_outward_rounded,
                color: Colors.black54,
              ),
              onTap: () {
                dialogContext.pop(MapsLaunchMode.openOnGoogleMaps);
              },
              shape: tileShape,
            ),
          ],
        ),
      ),
    );
  }
}
