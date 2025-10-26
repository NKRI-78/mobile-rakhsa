import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:rakhsa/misc/helpers/enum.dart';

import 'package:rakhsa/modules/nearme/domain/usecases/get_place_nearby.dart';
import 'package:rakhsa/modules/nearme/presentation/widgets/my_marker.dart';
import 'package:rakhsa/modules/nearme/presentation/widgets/widget_to_marker.dart';

class GetNearbyPlacenNotifier extends ChangeNotifier {
  final GetPlaceNearbyUseCase useCase;

  GetNearbyPlacenNotifier({required this.useCase});

  final List<Map<String, dynamic>> _entity = [];
  List<Map<String, dynamic>> get entity => [..._entity];

  final List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  String icon(String type) {
    switch (type) {
      case "mosque":
        return "mosque.png";
      case "church":
        return "church.png";
      case "hindu_temple":
        return "buddhist_temple.png";
      case "lodging":
        return "lodging.png";
      case "restaurant":
        return "restaurant.png";
      case "police":
        return "police.png";
      default:
        return "";
    }
  }

  Future<void> getNearme({
    required String type,
    required double currentLat,
    required double currentLng,
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    _markers.clear();
    _entity.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId("current_location"),
        position: LatLng(currentLat, currentLng),
        icon:
            await const TextOnImage(
              icon: "current-location.png",
              text: "Current Location",
            ).toBitmapDescriptor(
              logicalSize: const Size(150, 150),
              imageSize: const Size(150, 150),
            ),
        infoWindow: const InfoWindow(title: "Lokasi Anda"),
      ),
    );

    final result = await useCase.execute(
      type: type,
      currentLat: currentLat,
      currentLng: currentLng,
    );

    result.fold(
      (l) {
        _state = ProviderState.error;
        _message = l.message;
        notifyListeners();
      },
      (r) async {
        for (var el in r.results) {
          double distanceInMeters = Geolocator.distanceBetween(
            currentLat,
            currentLng,
            el.geometry.location.lat,
            el.geometry.location.lng,
          );

          double distanceInKm = distanceInMeters / 1000;

          _entity.add({
            "id": el.placeId,
            "name": el.name,
            "lat": el.geometry.location.lat.toString(),
            "lng": el.geometry.location.lng.toString(),
            "distance": distanceInKm.toStringAsFixed(2),
          });

          _markers.add(
            Marker(
              markerId: MarkerId(el.placeId),
              position: LatLng(
                el.geometry.location.lat,
                el.geometry.location.lng,
              ),
              icon:
                  await TextOnImage(
                    icon: icon(type),
                    text: "Current Location",
                  ).toBitmapDescriptor(
                    logicalSize: const Size(80, 80),
                    imageSize: const Size(80, 80),
                  ),
              infoWindow: InfoWindow(
                title: el.name,
                snippet: "${distanceInKm.toStringAsFixed(2)} km away",
              ),
            ),
          );
        }
        _state = ProviderState.loaded;
        notifyListeners();
      },
    );
  }
}
