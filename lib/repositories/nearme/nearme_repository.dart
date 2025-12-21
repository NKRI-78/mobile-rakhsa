import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rakhsa/core/client/dio_client.dart';
import 'package:rakhsa/core/client/errors/errors.dart';
import 'package:rakhsa/repositories/location/model/location_data.dart';

import 'model/google_maps_place.dart';

class NearMeRepository {
  final DioClient _client;

  const NearMeRepository(this._client);

  Dio get _mapsClient =>
      _client.createNewInstance(baseUrl: "https://maps.googleapis.com");

  Future<List<GoogleMapsPlace>> fetchNearbyPlaces(
    String type,
    Coord coord, {
    int distanceRadius = 3000,
  }) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) return <GoogleMapsPlace>[];

    try {
      if (!await _client.hasInternet) {
        throw NetworkException.noInternetConnection();
      }

      final res = await _mapsClient.get(
        '/maps/api/place/nearbysearch/json',
        queryParameters: {
          'location': '${coord.lat},${coord.lng}',
          'types': type,
          'radius': distanceRadius,
          'key': apiKey,
        },
      );

      if (res.data['results'] == null) return <GoogleMapsPlace>[];
      if (res.data['results'] is! List) return <GoogleMapsPlace>[];

      return (res.data['results'] as List).map((data) {
        final p = GoogleMapsPlace.fromJson(data);
        if (p.coord != null) {
          final d = Geolocator.distanceBetween(
            coord.lat,
            coord.lng,
            p.coord!.lat,
            p.coord!.lng,
          );
          return p.copyWith(type: type, distanceInMeters: d);
        }
        return p.copyWith(type: type);
      }).toList();
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    } catch (e) {
      throw _client.errorMapper(e);
    }
  }
}
