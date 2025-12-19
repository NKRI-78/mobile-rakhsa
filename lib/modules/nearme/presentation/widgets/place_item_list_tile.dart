import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/repositories/nearme/model/google_maps_place.dart';

class PlaceItemListTile extends StatelessWidget {
  const PlaceItemListTile({
    super.key,
    required this.place,
    required this.onPlaceSelected,
  });

  final GoogleMapsPlace place;
  final Future<void> Function(GoogleMapsPlace place) onPlaceSelected;

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
        onTap: () async => await onPlaceSelected(place),
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
}
