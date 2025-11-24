import 'package:rakhsa/misc/client/errors/errors.dart';

class LocationException implements Exception {
  LocationException(this.error);

  final LocationError error;
}
