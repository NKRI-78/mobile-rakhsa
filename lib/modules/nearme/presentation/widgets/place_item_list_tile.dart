import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/repositories/nearme/model/google_maps_place.dart';

enum PlaceSelectedMode { goToMaps, launchOnGoogleMaps }

class PlaceItemListTile extends StatelessWidget {
  const PlaceItemListTile({
    super.key,
    required this.place,
    required this.onPlaceSelected,
  });

  final GoogleMapsPlace place;
  final Future<void> Function(GoogleMapsPlace place, PlaceSelectedMode mode)
  onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    final dm = place.distanceInMeters;
    final dkm = dm / 1000;
    final distanceLabel = dm.toInt() < 1000
        ? "${dm.toInt()} m"
        : "${dkm.toStringAsFixed(2)} km";
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () async {
          if (place.coord != null) {
            await _showInGoogleMapsDialog(context, place);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  spacing: 2,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        distanceLabel,
                        style: TextStyle(
                          fontSize: 9,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    2.spaceY,
                    Text(
                      place.placeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (place.vicinity != null)
                      Text(
                        place.vicinity!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInGoogleMapsDialog(
    BuildContext context,
    GoogleMapsPlace place,
  ) async {
    final bottomBasedOS = Platform.isIOS ? 8.0 : 24.0;
    final bottomPadding = context.bottom + bottomBasedOS;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
            child: Column(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  place.placeName,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (place.vicinity != null)
                  Text(
                    place.vicinity!,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),

                16.spaceY,
                ListTile(
                  leading: Image.asset(
                    "assets/images/icons/maps.webp",
                    width: 32,
                    height: 32,
                  ),
                  title: Text("Maps"),
                  subtitle: Text("Lihat lokasi di Maps"),
                  trailing: Icon(
                    Icons.arrow_outward_rounded,
                    color: Colors.black54,
                  ),
                  onTap: () async {
                    dialogContext.pop();
                    await Future.delayed(Duration(milliseconds: 200));
                    onPlaceSelected(place, PlaceSelectedMode.goToMaps);
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/icons/google-maps.webp",
                    width: 32,
                    height: 32,
                  ),
                  title: Text("Google Maps"),
                  subtitle: Text("Buka menggunakan Google Maps"),
                  trailing: Icon(
                    Icons.arrow_outward_rounded,
                    color: Colors.black54,
                  ),
                  onTap: () async {
                    dialogContext.pop();
                    await Future.delayed(Duration(milliseconds: 200));
                    onPlaceSelected(
                      place,
                      PlaceSelectedMode.launchOnGoogleMaps,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
