import 'package:equatable/equatable.dart';

import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/repositories/location/model/location_data.dart';

class GoogleMapsPlace extends Equatable {
  final String type;
  final String placeId;
  final String placeName;
  final Coord? coord;
  final String? vicinity;
  final double distanceInMeters;

  const GoogleMapsPlace({
    required this.type,
    required this.placeId,
    required this.placeName,
    this.coord,
    this.vicinity,
    this.distanceInMeters = 0.0,
  });

  @override
  List<Object?> get props {
    return [type, placeId, placeName, coord, vicinity, distanceInMeters];
  }

  GoogleMapsPlace copyWith({
    String? type,
    String? placeId,
    String? placeName,
    Coord? coord,
    String? vicinity,
    double? distanceInMeters,
  }) {
    return GoogleMapsPlace(
      type: type ?? this.type,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      coord: coord ?? this.coord,
      vicinity: vicinity ?? this.vicinity,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'place_id': placeId,
      'name': placeName,
      'coord': coord?.toJson(),
      'vicinity': vicinity,
      'distance_in_meters': distanceInMeters,
    };
  }

  factory GoogleMapsPlace.fromJson(Map<String, dynamic> map) {
    try {
      return GoogleMapsPlace(
        // dibaca bro 😗😗 ini bukan tulisan ai yah
        // type dibuat kosong dulu karena nanti akan di-override didalam repository
        // type = police/mosque/lodging/restaurant sesuai dengan lemparan nilai dari halaman GoogleMapsPlaceGoogleMapsPlacesPage
        type: "",
        placeId: map['place_id'] ?? "",
        placeName: map['name'] ?? "",
        vicinity: map['vicinity'],
        coord: map['geometry']['location'] != null
            ? Coord.fromJson(map['geometry']['location'])
            : null,
      );
    } catch (e, st) {
      log("error data parsing GoogleMapsPlace = ${e.toString()}");
      log("stackTrace data parsing GoogleMapsPlace = ${st.toString()}");
      throw DataParsingException();
    }
  }
}

// contoh response /maps/api/place/nearbysearch/json
// {
//   "html_attributions": [],
//   "results": [
//     {
//       "business_status": "OPERATIONAL",
//       "geometry": {
//         "location": {
//           "lat": -6.253281899999998,
//           "lng": 106.7985544
//         },
//         "viewport": {
//           "northeast": {
//             "lat": -6.251891619708497,
//             "lng": 106.7998980802915
//           },
//           "southwest": {
//             "lat": -6.254589580291502,
//             "lng": 106.7972001197085
//           }
//         }
//       },
//       "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/civic_building-71.png",
//       "icon_background_color": "#7B9EB0",
//       "icon_mask_base_uri": "https://maps.gstatic.com/mapfiles/place_api/icons/v2/civic-bldg_pinlet",
//       "international_phone_number": "+62 21 7206004",
//       "name": "South Jakarta Metro Police",
//       "photos": [
//         {
//           "height": 1080,
//           "html_attributions": [
//             "<a href=\"https://maps.google.com/maps/contrib/112825738376825362404\">Faisyal Hakim</a>"
//           ],
//           "photo_reference": "AZLasHoPzWsXWPrDD0_zK-koYwSqwBlPwC3p9wRIHx1uq68RCTxBsIqwIz89cjwM0FSV98TKSwsA8CLm1OCg1D16OmosiBhA_mW3SId1j0dAnx80ROxNg-XeOoMH_3H7WvzIwXkH6_aLb5aIBB4BM0SNcA1W9eQGXL_pOEdIoiBlnlhKk3tzAvWiF5ysoAMe4NiUCk5zOc8oRVsKPIrWK8G0UtgzwpmCpZp4TqK0P8uBNXodxkOqzJrxnQw30Nuib2i2w0ZFxsMHeB-kKsRzfdmCqlrlUq06V6v6iXrIiffL_Ypucsr_9oSeuHZx6yoLiJFl15rpZCCKsIRCRvsYECCnDAS6bLEYMZfu8SBcD-8yCSojNa7BwM-BDfg40V0-AbIyF7V2b15uRokthCyHIoU96HYLOJMl7h39buXYJqoBLxLLkcelvNP4halT9Qgk7aNgrnZwExoEq2cx2WdincKkqo1dff6YZ65rvhLDJLemDi1iUYj0J7NOycTa4Uf_5J1hBrQD3wcXns-E5HRaQkNmn1LYJJR8D0D2m9rKFQDSKQZeqcNqRIXOSYGRcQhcLmFNxbAh1rTyQpsvhdvZgJoOggfGH-sEJv1RJ3uROGK3BN3_D2Mbjdzk64TbaqjFOVEnVOEpqw",
//           "width": 1920
//         }
//       ],
//       "place_id": "ChIJ4aOYEnHxaS4RpZ85KeNO0Wk",
//       "plus_code": {
//         "compound_code": "PQWX+MC Pulo, South Jakarta City, Jakarta, Indonesia",
//         "global_code": "6P58PQWX+MC"
//       },
//       "reference": "ChIJ4aOYEnHxaS4RpZ85KeNO0Wk",
//       "scope": "GOOGLE",
//       "types": ["police", "point_of_interest", "establishment"],
//       "vicinity": "Jalan Wijaya II No.42 2, RT.2/RW.1, Pulo"
//     }
//   ],
//   "status": "OK"
// }
