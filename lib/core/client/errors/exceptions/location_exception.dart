import 'package:rakhsa/core/client/errors/errors.dart';

class LocationException implements Exception {
  LocationException(this.error);

  final LocationError error;
}
