import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

class CurrentLocationWidget extends StatelessWidget {
  final String avatar;
  final bool loadingGmaps;
  final List<Marker> markers;
  final String currentAddress;
  final String currentLat;
  final String currentLng;

  const CurrentLocationWidget({
    required this.avatar,
    required this.loadingGmaps,
    required this.markers,
    required this.currentAddress,
    required this.currentLat,
    required this.currentLng,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: Card(
        color: ColorResources.white,
        surfaceTintColor: ColorResources.white,
        elevation: 1.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    context.watch<ProfileNotifier>().state ==
                            ProviderState.error
                        ? const SizedBox()
                        : context.watch<ProfileNotifier>().state ==
                              ProviderState.loading
                        ? const SizedBox()
                        : CachedNetworkImage(
                            imageUrl: avatar.toString(),
                            imageBuilder:
                                (
                                  BuildContext context,
                                  ImageProvider<Object> imageProvider,
                                ) {
                                  return CircleAvatar(
                                    backgroundImage: imageProvider,
                                  );
                                },
                            placeholder: (BuildContext context, String url) {
                              return const CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/default.jpeg',
                                ),
                              );
                            },
                            errorWidget:
                                (
                                  BuildContext context,
                                  String url,
                                  Object error,
                                ) {
                                  return const CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/images/default.jpeg',
                                    ),
                                  );
                                },
                          ),

                    const SizedBox(width: 15.0),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Posisi Anda saat ini",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4.0),

                          Text(
                            loadingGmaps ? "Mohon tunggu..." : currentAddress,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: ColorResources.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Container(
                  width: double.infinity,
                  height: 120.0,
                  margin: const EdgeInsets.only(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: loadingGmaps
                      ? const SizedBox()
                      : GoogleMap(
                          mapType: MapType.normal,
                          gestureRecognizers: {}
                            ..add(
                              Factory<EagerGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            ),
                          myLocationEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              double.parse(currentLat),
                              double.parse(currentLng),
                            ),
                            zoom: 12.0,
                          ),
                          markers: Set.from(markers),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
