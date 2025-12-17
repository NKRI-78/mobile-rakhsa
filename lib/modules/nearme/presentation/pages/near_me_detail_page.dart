import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/modules/nearme/presentation/widgets/place_item_list_tile.dart';
import 'package:rakhsa/repositories/nearme/model/google_maps_place.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/widgets/dialog/app_dialog.dart';
import 'package:rakhsa/widgets/lottie/lottie_animation.dart' as la;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/modules/nearme/presentation/provider/near_me_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NearMeDetailPage extends StatefulWidget {
  const NearMeDetailPage({super.key, required this.type});

  final String type;

  @override
  State<NearMeDetailPage> createState() => NearMeDetailPageState();
}

class NearMeDetailPageState extends State<NearMeDetailPage> {
  late LocationProvider _locationProvider;
  late NearMeProvider _nearmeProvider;

  final _mapCompletter = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _locationProvider = context.read<LocationProvider>();
    _nearmeProvider = context.read<NearMeProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    Future.microtask(_fetchNearMe);
  }

  @override
  void dispose() {
    _mapCompletter.future.then((c) => c.dispose());
    super.dispose();
  }

  Future<void> _fetchNearMe() async {
    if (!mounted) return;
    await _locationProvider.getCurrentLocation();

    if (!mounted) return;
    final coord = _locationProvider.location?.coord;
    if (coord != null) {
      await _nearmeProvider.fetchNearbyPlaces(widget.type, coord);
    }
  }

  Future<void> _goToMaps(Coord c, MarkerId? markerId) async {
    try {
      final mapController = await _mapCompletter.future;
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(c.lat, c.lng), 18.0),
      );
      if (markerId != null) {
        await mapController.showMarkerInfoWindow(markerId);
      }
    } catch (e) {
      log("error navigate to maps = ${e.toString()}");
    }
  }

  Future<void> _launchOnGoogleMaps(String placeId, String placeName) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${Uri.encodeComponent(placeName)}'
      '&query_place_id=$placeId',
    );
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
      } catch (e) {
        AppDialog.showToast("Tidak bisa membuka maps");
      } finally {
        AppDialog.dismissLoading();
      }
    } else {
      AppDialog.dismissLoading();
      AppDialog.showToast("Tidak bisa membuka maps");
    }
  }

  String get _title => switch (widget.type) {
    "police" => "Kantor Polisi",
    "mosque" => "Tempat Ibadah",
    "lodging" => "Penginapan",
    _ => "Restoran",
  };

  String get _iconAsset => switch (widget.type) {
    "police" => "assets/images/icons/police.png",
    "mosque" => "assets/images/icons/mosque.png",
    "restaurant" => "assets/images/icons/restaurant.png",
    _ => "assets/images/icons/lodging.png",
  };

  @override
  Widget build(BuildContext context) {
    final animSize = 150.toDouble();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_title),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade50,
      body: Consumer2<NearMeProvider, LocationProvider>(
        builder: (context, np, lp, child) {
          // kalo ga sukses get lokasi sama ga sukses fetch places
          if (!lp.isGetLocationState(RequestState.success) ||
              !np.state.isSuccess) {
            return _buildIdleState(animSize, "Mencari $_title terdekat…");
          }

          final coord = lp.location?.coord;
          if (coord == null) {
            return _buildIdleState(animSize, "Lokasi Anda tidak ditemukan.");
          }

          final filteredLocations = np.state.places.filterByPlaceType(
            widget.type,
          );

          final nearest = filteredLocations.findNearestByDistance();

          final placeMarkers = filteredLocations.generateMarker(_iconAsset);
          final selfMarker = _buildSelfLocationMarker(coord);
          final allMarkers = {...placeMarkers, selfMarker};

          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  onMapCreated: (controller) {
                    if (_mapCompletter.isCompleted) return;
                    _mapCompletter.complete(controller);
                  },
                  gestureRecognizers: {}
                    ..add(
                      Factory<EagerGestureRecognizer>(() {
                        return EagerGestureRecognizer();
                      }),
                    ),
                  markers: allMarkers,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(coord.lat, coord.lng),
                    zoom: 17.0,
                  ),
                ),
              ),

              if (nearest != null)
                Builder(
                  builder: (_) {
                    final dm = nearest.distanceInMeters;
                    final dkm = dm / 1000;
                    final distanceLabel = dm.toInt() < 1000
                        ? "${dm.toInt()} meter"
                        : "${dkm.toStringAsFixed(2)} km";

                    return Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Material(
                        elevation: 10,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        shadowColor: Colors.black38,
                        child: ListTile(
                          leading: Icon(IconsaxPlusBold.location),
                          title: Text("$_title Terdekat"),
                          subtitle: Text(
                            "${nearest.placeName} ($distanceLabel)",
                          ),
                          trailing: Icon(IconsaxPlusBold.menu_1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () async {
                            await _showPlacesModalDialog(
                              filteredLocations,
                              allMarkers,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIdleState(double size, String subtitle) {
    return SizedBox.expand(
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          la.LottieAnimation(
            "assets/animations/search-location.lottie",
            width: size,
            height: size,
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87),
          ),

          56.spaceY,
        ],
      ),
    );
  }

  Marker _buildSelfLocationMarker(Coord c) {
    return Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(c.lat, c.lng),
      icon: AssetMapBitmap(
        "assets/images/icons/current-location.png",
        height: 50,
        width: 50,
      ),
      infoWindow: const InfoWindow(title: 'Lokasi Anda'),
    );
  }

  Future<Coord?> _showPlacesModalDialog(
    List<GoogleMapsPlace> places,
    Set<Marker> markers,
  ) async {
    final sortedPlaces = [...places]
      ..sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
    final bottomBasedOS = Platform.isIOS ? 8.0 : 24.0;
    final bottomPadding = context.bottom + bottomBasedOS;
    return showModalBottomSheet<Coord?>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade100,
      constraints: BoxConstraints(maxHeight: context.getScreenHeight(0.9)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.98,
          minChildSize: 0.4,
          initialChildSize: 0.8,
          builder: (context, scrollController) {
            return ListView.separated(
              controller: scrollController,
              itemCount: sortedPlaces.length,
              padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding),
              separatorBuilder: (context, index) => 12.spaceY,
              itemBuilder: (context, index) {
                final place = sortedPlaces[index];
                return PlaceItemListTile(
                  place: place,
                  onPlaceSelected: (place, mode) async {
                    modalContext.pop();

                    AppDialog.showLoading(context);

                    final marker = markers.findMarkerByPlaceName(
                      place.placeName,
                    );

                    AppDialog.dismissLoading();
                    if (mode == PlaceSelectedMode.goToMaps) {
                      if (place.coord != null) {
                        await _goToMaps(place.coord!, marker?.markerId);
                      }
                    } else {
                      await _launchOnGoogleMaps(place.placeId, place.placeName);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

extension MarkersExtension on Set<Marker> {
  Marker? findMarkerByPlaceName(String placeName) {
    for (final m in this) {
      if (m.infoWindow.title == placeName) {
        return m;
      }
    }
    return null;
  }
}

extension FilteredPlacesExtension on List<GoogleMapsPlace> {
  Set<Marker> generateMarker(String iconAsset) {
    return map((e) {
      final dm = e.distanceInMeters;
      final dkm = dm / 1000;
      final distanceDescription = dm.toInt() < 1000
          ? "${dm.toInt()} meter dari sini"
          : "${dkm.toStringAsFixed(2)} km dari sini";
      return Marker(
        markerId: MarkerId(e.placeId),
        position: LatLng(e.coord?.lat ?? 0.0, e.coord?.lng ?? 0.0),
        icon: AssetMapBitmap(iconAsset, height: 50, width: 50),
        infoWindow: InfoWindow(
          title: e.placeName,
          snippet: distanceDescription,
        ),
      );
    }).toSet();
  }
}
