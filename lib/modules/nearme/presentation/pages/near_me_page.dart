import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/nearme/presentation/provider/nearme_notifier.dart';

class NearMePage extends StatefulWidget {
  const NearMePage({super.key, required this.type});

  final String type;

  @override
  State<NearMePage> createState() => NearMePageState();
}

class NearMePageState extends State<NearMePage> {
  late UserProvider profileNotifier;
  late GetNearbyPlacenNotifier getNearbyPlaceReligionNotifier;
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    profileNotifier = context.read<UserProvider>();
    getNearbyPlaceReligionNotifier = context.read<GetNearbyPlacenNotifier>();

    Future.microtask(() async {
      await getData();
      addUserRangePolyline();
    });
  }

  Future<void> launchMapsUrl(double lat, double lng) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(Uri.parse(uri.toString()))) {
      await launchUrl(Uri.parse(uri.toString()));
    } else {
      throw 'Could not open maps';
    }
  }

  Future<void> getData() async {
    if (!mounted) return;
    await profileNotifier.getUser(enableCache: true);

    if (!mounted) return;
    await getNearbyPlaceReligionNotifier.getNearme(
      type: widget.type,
      currentLat: double.parse(profileNotifier.user?.lat ?? "0.0"),
      currentLng: double.parse(profileNotifier.user?.lng ?? "0.0"),
    );
  }

  void addUserRangePolyline() {
    if (!mounted) return;

    final userLat = double.parse(profileNotifier.user?.lat ?? "0");
    final userLng = double.parse(profileNotifier.user?.lng ?? "0");

    Set<Polyline> newPolylines = {};

    for (var place in getNearbyPlaceReligionNotifier.entity) {
      final placeLat = double.parse(place["lat"]);
      final placeLng = double.parse(place["lng"]);

      final polyline = Polyline(
        polylineId: PolylineId('${userLat}_${userLng}_${placeLat}_$placeLng'),
        points: [LatLng(userLat, userLng), LatLng(placeLat, placeLng)],
        color: Colors.blue,
        width: 5,
      );

      newPolylines.add(polyline);
    }

    setState(() {
      polylines = newPolylines;
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Text(
          statusType(widget.type),
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: ColorResources.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorResources.backgroundColor,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: ColorResources.black,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Consumer<GetNearbyPlacenNotifier>(
          builder: (context, notifier, child) {
            if (notifier.state == ProviderState.loading) {
              return Center(
                child: Column(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitChasingDots(color: Color(0xFFFE1717)),
                    Text(
                      "Memuat Lokasi",
                      style: TextStyle(
                        color: errorColor,
                        fontSize: fontSizeDefault,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (notifier.state == ProviderState.error) {
              return Center(
                child: Text(
                  notifier.message,
                  style: robotoRegular.copyWith(color: ColorResources.black),
                ),
              );
            }

            double userLat = double.parse(profileNotifier.user?.lat ?? "0");
            double userLng = double.parse(profileNotifier.user?.lng ?? "0");

            // Find nearest place based on user location
            Map<String, dynamic>? nearestPlace;
            double minDistance = double.infinity;

            for (var place in notifier.entity) {
              double placeLat = double.parse(place["lat"]);
              double placeLng = double.parse(place["lng"]);

              double distance = calculateDistance(
                userLat,
                userLng,
                placeLat,
                placeLng,
              );

              if (distance < minDistance) {
                minDistance = distance;
                nearestPlace = place;
              }
            }

            String nearestLocation = nearestPlace != null
                ? "${nearestPlace["name"]} (${minDistance.toStringAsFixed(2)} KM)"
                : "No nearby places found";
            return ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(16),
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    gestureRecognizers: {}
                      ..add(
                        Factory<EagerGestureRecognizer>(() {
                          return EagerGestureRecognizer();
                        }),
                      ),
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(userLat, userLng),
                      zoom: 18.0,
                    ),
                    markers: Set.from(notifier.markers),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          Expanded(
                            child: Text(
                              "Nearest: $nearestLocation",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.bold,
                                color: ColorResources.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.directions,
                              color: Colors.blue,
                              size: 26.0,
                            ),
                            onPressed: () {
                              if (nearestPlace != null) {
                                double lat = double.parse(nearestPlace["lat"]);
                                double lng = double.parse(nearestPlace["lng"]);
                                launchMapsUrl(lat, lng);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
