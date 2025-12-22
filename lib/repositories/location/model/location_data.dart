// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart' show Placemark;

export 'package:geocoding/geocoding.dart' show Placemark;

class LocationData extends Equatable {
  final Coord coord;
  final Placemark? placemark;

  const LocationData({required this.coord, this.placemark});

  @override
  List<Object?> get props => [coord, placemark];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'coord': coord.toJson(),
      'placemark': placemark?.toJson(),
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      coord: Coord.fromJson(map['coord'] as Map<String, dynamic>),
      placemark: map['placemark'] != null
          ? Placemark.fromMap(map['placemark'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationData.fromJson(String source) =>
      LocationData.fromMap(json.decode(source) as Map<String, dynamic>);

  LocationData copyWith({Coord? coord, Placemark? placemark}) {
    return LocationData(
      coord: coord ?? this.coord,
      placemark: placemark ?? this.placemark,
    );
  }

  @override
  bool get stringify => true;
}

class Coord extends Equatable {
  final double lat;
  final double lng;

  const Coord(this.lat, this.lng);

  @override
  List<Object> get props => [lat, lng];

  Coord copyWith({double? lat, double? lng}) {
    return Coord(lat ?? this.lat, lng ?? this.lng);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'lat': lat, 'lng': lng};
  }

  factory Coord.fromJson(Map<String, dynamic> map) {
    return Coord(map['lat'] as double, map['lng'] as double);
  }

  @override
  bool get stringify => true;
}