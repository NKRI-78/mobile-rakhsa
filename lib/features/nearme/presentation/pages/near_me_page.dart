import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/nearme/presentation/provider/nearme_religion_notifier.dart';

class NearMePage extends StatefulWidget {
  const NearMePage({super.key, required this.type});

  final String type;

  @override
  State<NearMePage> createState() => NearMePageState();
}

class NearMePageState extends State<NearMePage> {
  
  late ProfileNotifier profileNotifier;
  late GetNearbyPlaceReligionNotifier getNearbyPlaceReligionNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      await profileNotifier.getProfile();

    if(!mounted) return;
      await getNearbyPlaceReligionNotifier.getNearmeReligion(
        keyword: "", 
        currentLat: double.parse(profileNotifier.entity.data!.lat), 
        currentLng: double.parse(profileNotifier.entity.data!.lng)
      );
  }

  @override
  void initState() {
    super.initState();

    profileNotifier = context.read<ProfileNotifier>();
    getNearbyPlaceReligionNotifier = context.read<GetNearbyPlaceReligionNotifier>();

    Future.microtask(() => getData());
  }
  
  
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