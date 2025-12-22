import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/core/debug/logger.dart';
import 'package:rakhsa/modules/nearme/presentation/widgets/maps_mode_dialog.dart';
import 'package:rakhsa/modules/nearme/presentation/widgets/place_item_list_tile.dart';
import 'package:rakhsa/repositories/nearme/model/google_maps_place.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:rakhsa/widgets/lottie_animation.dart' as la;
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

  GoogleMapController? _mapController;

  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _locationProvider = context.read<LocationProvider>();
    _nearmeProvider = context.read<NearMeProvider>();

    Future.microtask(_fetchNearMe);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMapStyle();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
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

  void _loadMapStyle() async {
    final style = await rootBundle.loadString(Assets.jsonGoogleMapsStyle);
    if (mounted) {
      _mapStyle = style;
      setState(() {});
    }
  }

  Future<void> _goToMaps(GoogleMapsPlace place, MarkerId? mid) async {
    final coord = place.coord;
    if (coord == null) return;

    try {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(coord.lat, coord.lng), 18.0),
        duration: Duration(milliseconds: 700),
      );
      if (mid != null) {
        await _mapController?.showMarkerInfoWindow(mid);
      }
    } catch (e) {
      log("error navigate to maps = ${e.toString()}");
    }
  }

  Future<void> _launchOnGoogleMaps(GoogleMapsPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${Uri.encodeComponent(place.placeName)}'
      '&query_place_id=${place.placeId}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppDialog.showToast("Tidak bisa membuka maps");
    }
  }

  Future<void> _launchOnAppleMaps(GoogleMapsPlace place) async {
    final label = place.placeName;
    final coord = place.coord;
    if (coord == null) return;

    final uri = Uri.parse(
      'https://maps.apple.com/?ll=${coord.lat},${coord.lng}'
      '&q=${Uri.encodeComponent(label)}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
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
    "police" => Assets.imagesNearmeMapsPolice,
    "mosque" => Assets.imagesNearmeMapsMosque,
    "restaurant" => Assets.imagesNearmeMapsRestaurant,
    _ => Assets.imagesNearmeMapsLodging,
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
          if (!lp.isGetLocationState(.success) || !np.state.isSuccess) {
            return _buildIdleState(animSize, "Mencari $_title terdekat…");
          }

          final coord = lp.location?.coord;
          if (coord == null) {
            return _buildIdleState(animSize, "Lokasi Anda tidak ditemukan.");
          }

          final placeMarkers = _generateMarkers(np.state.places);
          final selfMarker = _buildSelfLocationMarker(coord);
          final allMarkers = {...placeMarkers, selfMarker};

          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  style: _mapStyle,
                  markers: allMarkers,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  padding: .only(bottom: context.bottom + 16),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  gestureRecognizers: {}
                    ..add(
                      Factory<EagerGestureRecognizer>(() {
                        return EagerGestureRecognizer();
                      }),
                    ),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(coord.lat, coord.lng),
                    zoom: 17.0,
                  ),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 10,
                  color: Colors.white,
                  borderRadius: .circular(8),
                  shadowColor: Colors.black38,
                  child: ListTile(
                    leading: Icon(IconsaxPlusBold.menu_1),
                    title: Text(
                      "${np.state.places.length} $_title Terdekat Ditemukan",
                      style: TextStyle(fontSize: 13, fontWeight: .bold),
                    ),
                    subtitle: Text(
                      "Menampilkan lokasi terdekat dalam radius 3 kilometer",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                    onTap: () async {
                      HapticService.instance.lightImpact();
                      await _showPlacesModalDialog(np.state.places, allMarkers);
                    },
                  ),
                ),
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
        mainAxisAlignment: .center,
        children: [
          la.LottieAnimation(
            Assets.animationsSearchLocation,
            width: size,
            height: size,
          ),
          Text(
            subtitle,
            textAlign: .center,
            style: TextStyle(color: Colors.black87),
          ),

          56.spaceY,
        ],
      ),
    );
  }

  Marker _buildSelfLocationMarker(Coord c) {
    return Marker(
      markerId: MarkerId('current_location'),
      position: LatLng(c.lat, c.lng),
      icon: AssetMapBitmap(
        Assets.imagesNearmeMapsCurrentLocation,
        height: 50,
        width: 50,
      ),
      infoWindow: const InfoWindow(title: 'Lokasi Anda'),
    );
  }

  Set<Marker> _generateMarkers(List<GoogleMapsPlace> places) {
    return places.map((place) {
      final dm = place.distanceInMeters;
      final dkm = dm / 1000;
      final distanceDescription = dm.toInt() < 1000
          ? "${dm.toInt()} m"
          : "${dkm.toStringAsFixed(2)} km";

      final mid = MarkerId(place.placeId);

      void showLaunchModeDialog() async {
        await HapticService.instance.lightImpact();
        if (!mounted) return;

        final mode = await MapsLaunchModeDialog.launch(
          context,
          place,
          fromMapsTile: true,
        );
        if (mode != null) {
          if (mounted) AppDialog.showLoading(context);
          await Future.delayed(Duration(milliseconds: 200));
          AppDialog.dismissLoading();

          switch (mode) {
            case .goToMaps:
              await _goToMaps(place, mid);
              break;
            case .openOnAppleMaps:
              await _launchOnAppleMaps(place);
              break;
            case .openOnGoogleMaps:
              await _launchOnGoogleMaps(place);
              break;
          }
        }
      }

      return Marker(
        markerId: mid,
        position: LatLng(place.coord?.lat ?? 0.0, place.coord?.lng ?? 0.0),
        icon: AssetMapBitmap(_iconAsset, height: 50, width: 50),
        infoWindow: InfoWindow(
          title: place.placeName,
          snippet: distanceDescription,
          onTap: showLaunchModeDialog,
        ),
        onTap: showLaunchModeDialog,
      );
    }).toSet();
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
        borderRadius: .vertical(top: .circular(16)),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.98,
          minChildSize: 0.4,
          initialChildSize: 0.8,
          builder: (_, scrollController) {
            return ListView.separated(
              controller: scrollController,
              itemCount: sortedPlaces.length,
              padding: .fromLTRB(12, 0, 12, bottomPadding),
              separatorBuilder: (context, index) => 12.spaceY,
              itemBuilder: (_, index) {
                final place = sortedPlaces[index];
                return PlaceItemListTile(
                  place: place,
                  onPlaceSelected: (place) async {
                    final mode = await MapsLaunchModeDialog.launch(
                      context,
                      place,
                    );
                    if (mode != null) {
                      if (mounted) AppDialog.showLoading(context);
                      await Future.delayed(Duration(milliseconds: 200));
                      AppDialog.dismissLoading();
                      if (modalContext.mounted) modalContext.pop();

                      switch (mode) {
                        case .goToMaps:
                          final marker = markers.findMarkerByPlaceName(
                            place.placeName,
                          );
                          await _goToMaps(place, marker?.markerId);
                          break;
                        case .openOnAppleMaps:
                          await _launchOnAppleMaps(place);
                          break;
                        case .openOnGoogleMaps:
                          await _launchOnGoogleMaps(place);
                          break;
                      }
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
