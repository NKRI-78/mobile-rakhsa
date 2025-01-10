import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/nearme/presentation/provider/nearme_notifier.dart';

class NearMePage extends StatefulWidget {
  const NearMePage({super.key, required this.type});

  final String type;

  @override
  State<NearMePage> createState() => NearMePageState();
}

class NearMePageState extends State<NearMePage> {
  
  late ProfileNotifier profileNotifier;
  late GetNearbyPlacenNotifier getNearbyPlaceReligionNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      await profileNotifier.getProfile();

    if(!mounted) return;
      await getNearbyPlaceReligionNotifier.getNearmeReligion(
        type: widget.type,
        currentLat: double.parse(profileNotifier.entity.data!.lat), 
        currentLng: double.parse(profileNotifier.entity.data!.lng)
      );
  }

  @override
  void initState() {
    super.initState();

    profileNotifier = context.read<ProfileNotifier>();
    getNearbyPlaceReligionNotifier = context.read<GetNearbyPlacenNotifier>();

    Future.microtask(() => getData());
  }
  
  String statusType(String type) {
    switch (type) {
      case "mosque":
        return "Tempat Ibadah";
      case "lodging": 
        return "Hotel";
      case "police": 
        return "Polisi";
      case "restaurant": 
        return "Restoran";
      default:
      return "";
    }    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GetNearbyPlacenNotifier>(
        builder: (BuildContext context, GetNearbyPlacenNotifier notifier, Widget? child) {
          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                title: Text(statusType(widget.type),
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: ColorResources.black
                  ),
                ),
                centerTitle: true,
                backgroundColor: ColorResources.backgroundColor,
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color: ColorResources.black,
                ),
              ),

              // Title pilih negara
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 25.0,
                    bottom: 5.0,
                    left: 16.0, 
                    right: 16.0
                  ),
                  child: Text(
                    "Pilih negara terlebih dahulu...",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),  

              if(notifier.state == ProviderState.loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: Center(
                      child: CircularProgressIndicator()
                    )
                  )
                ),

              
              if(notifier.state == ProviderState.empty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                  child: Text("Data tidak ditemukan",
                    style: robotoRegular.copyWith(
                      color: ColorResources.black
                    ),
                  ))
                ),

              if(notifier.state == ProviderState.error)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(notifier.message,
                      style: robotoRegular.copyWith(
                        color: ColorResources.black
                      ),
                    )
                  )
                ),

              if(notifier.state == ProviderState.loaded)
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
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              double.parse(profileNotifier.entity.data!.lat),
                              double.parse(profileNotifier.entity.data!.lng),
                            ),
                            zoom: 12.0,
                          ),
                          markers: Set.from(notifier.markers),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ); 
        },
      ) 
    );
  }
}