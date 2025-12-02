import 'package:rakhsa/modules/location/provider/location_provider.dart';

extension PlacemarkExtension on Placemark {
  String getAddress([
    List<PlacemarkPart> parts = const [
      PlacemarkPart.administrativeArea,
      PlacemarkPart.subAdministrativeArea,
      PlacemarkPart.street,
      PlacemarkPart.country,
    ],
  ]) {
    final values = <String>[];

    for (final part in parts) {
      final value = part.getValue(this);

      if (value != null) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          values.add(trimmed);
        }
      }
    }

    if (values.isEmpty) return "-";

    return values.join(', ');
  }
}
