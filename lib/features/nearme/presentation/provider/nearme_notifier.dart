import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/nearme/domain/usecases/get_place_nearby.dart';

class GetNearbyPlacenNotifier extends ChangeNotifier {
  final GetPlaceNearbyUseCase useCase;

  GetNearbyPlacenNotifier({required this.useCase});

  List<Map<String, dynamic>> _entity = [];
  List<Map<String, dynamic>> get entity => [..._entity];

  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> getNearmeReligion({
    required String type,
    required double currentLat,
    required double currentLng,
  }) async {
    _state = ProviderState.loading;
    Future.delayed(Duration.zero, () => notifyListeners());

    _markers = [];
    _entity = []; 

    final result = await useCase.execute(
      type: type,
      currentLat: currentLat,
      currentLng: currentLng,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("CurrentLocation"),
        position: LatLng(currentLat, currentLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      )
    );

    result.fold(
      (l) {
        _state = ProviderState.error;
        _message = l.message;
        notifyListeners();
      },
      (r) {

        for (var el in r.results) {
          _markers.add(
            Marker(
              markerId: MarkerId(el.placeId),
              position: LatLng(el.geometry.location.lat, el.geometry.location.lng),
              infoWindow: InfoWindow(
                title: el.name
              )
            )
          );
        } 

        _state = ProviderState.loaded;
        Future.delayed(Duration.zero, () => notifyListeners());

        if(markers.isEmpty) {
          _state = ProviderState.empty;
          Future.delayed(Duration.zero, () => notifyListeners());
        }

      },
    );
  }
}