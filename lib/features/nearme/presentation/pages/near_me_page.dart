import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import '../../../../common/utils/custom_themes.dart';

class NearMePage extends StatelessWidget {
  const NearMePage({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: ColorResources.backgroundColor,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
              color: ColorResources.black,
            ),
          ),

          // Title pilih negara
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                "Pilih negara terlebih dahulu...",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Google Maps with expanded behavior
          SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    gestureRecognizers: {}
                      ..add(Factory<EagerGestureRecognizer>(() {
                        return EagerGestureRecognizer();
                      })),
                    myLocationEnabled: false,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(
                        -6.229366230669683,
                        106.79943515329535,
                      ),
                      zoom: 12.0,
                    ),
                    markers: Set.from([]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}