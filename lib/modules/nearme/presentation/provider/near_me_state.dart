// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:rakhsa/core/client/errors/errors.dart';
import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/repositories/nearme/model/google_maps_place.dart';

class NearMeState extends Equatable {
  final List<GoogleMapsPlace> places;
  final RequestState state;
  final ErrorState? error;

  const NearMeState({
    this.places = const <GoogleMapsPlace>[],
    this.state = .idle,
    this.error,
  });

  bool get isLoading => state == .loading;
  bool get isError => state == .error;
  bool get isSuccess => state == .success;

  @override
  List<Object?> get props => [places, state, error];

  NearMeState copyWith({
    List<GoogleMapsPlace>? places,
    RequestState? state,
    ErrorState? error,
  }) {
    return NearMeState(
      places: places ?? this.places,
      state: state ?? this.state,
      error: error ?? this.error,
    );
  }
}

extension NearMeStateExtension on List<GoogleMapsPlace> {
  GoogleMapsPlace? findNearestByDistance() {
    if (isEmpty) return null;
    return reduce((a, b) {
      return a.distanceInMeters <= b.distanceInMeters ? a : b;
    });
  }

  List<GoogleMapsPlace> filterByPlaceType(String type) {
    return where((item) => item.type == type).toList();
  }

  bool hasType(String type) {
    return any((e) => e.type == type);
  }
}
