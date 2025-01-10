class NearbyplaceModel {
  NearbyplaceModel({
    required this.htmlAttributions,
    required this.results,
    required this.status,
  });

  List<dynamic> htmlAttributions;
  List<NearbyplaceResponse> results;
  String status;

  factory NearbyplaceModel.fromJson(Map<String, dynamic> json) => NearbyplaceModel(
    htmlAttributions: List<dynamic>.from(json["html_attributions"].map((x) => x)),
    results: List<NearbyplaceResponse>.from(json["results"].map((x) => NearbyplaceResponse.fromJson(x))),
    status: json["status"],
  );
}

class NearbyplaceResponse {
  NearbyplaceResponse({
    required this.businessStatus,
    required this.geometry,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconMaskBaseUri,
    required this.name,
    this.openingHours,
    this.photos,
    required this.placeId,
    required this.rating,
    required this.reference,
    required this.scope,
    required this.types,
    required this.userRatingsTotal,
    required this.vicinity,
    this.plusCode,
  });

  String businessStatus;
  Geometry geometry;
  String icon;
  IconBackgroundColor iconBackgroundColor;
  String iconMaskBaseUri;
  String name;
  OpeningHours? openingHours;
  List<Photo>? photos;
  String placeId;
  double rating;
  String reference;
  Scope scope;
  List<Type> types;
  int userRatingsTotal;
  String vicinity;
  PlusCode? plusCode;

  factory NearbyplaceResponse.fromJson(Map<String, dynamic> json) => NearbyplaceResponse(
    businessStatus: json["business_status"],
    geometry: Geometry.fromJson(json["geometry"]),
    icon: json["icon"],
    iconBackgroundColor: iconBackgroundColorValues.map[json["icon_background_color"]]!,
    iconMaskBaseUri: json["icon_mask_base_uri"],
    name: json["name"],
    openingHours: json["opening_hours"] == null ? null : OpeningHours.fromJson(json["opening_hours"]),
    photos: json["photos"] == null ? [] : List<Photo>.from(json["photos"]!.map((x) => Photo.fromJson(x))),
    placeId: json["place_id"],
    rating: json["rating"]?.toDouble(),
    reference: json["reference"],
    scope: scopeValues.map[json["scope"]]!,
    types: List<Type>.from(json["types"].map((x) => typeValues.map[x]!)),
    userRatingsTotal: json["user_ratings_total"],
    vicinity: json["vicinity"],
    plusCode: json["plus_code"] == null ? null : PlusCode.fromJson(json["plus_code"]),
  );
}

enum BusinessStatus { operational }

final businessStatusValues = EnumValues({
    "OPERATIONAL": BusinessStatus.operational
});

class Geometry {
  Geometry({
    required this.location,
    required this.viewport,
  });

  Location location;
  Viewport viewport;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    location: Location.fromJson(json["location"]),
    viewport: Viewport.fromJson(json["viewport"]),
  );
}

class Location {
  Location({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
  );
}

class Viewport {
  Viewport({
    required this.northeast,
    required this.southwest,
  });

  Location northeast;
  Location southwest;

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
    northeast: Location.fromJson(json["northeast"]),
    southwest: Location.fromJson(json["southwest"]),
  );
}

enum IconBackgroundColor { the7B9EB0 }

final iconBackgroundColorValues = EnumValues({
    "#7B9EB0": IconBackgroundColor.the7B9EB0
});

class OpeningHours {
  OpeningHours({
    required this.openNow,
  });

  bool openNow;

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
    openNow: json["open_now"],
  );
}

class Photo {
  Photo({
    required this.height,
    required this.htmlAttributions,
    required this.photoReference,
    required this.width,
  });

  int height;
  List<String> htmlAttributions;
  String photoReference;
  int width;

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    height: json["height"],
    htmlAttributions: List<String>.from(json["html_attributions"].map((x) => x)),
    photoReference: json["photo_reference"],
    width: json["width"],
  );
}

class PlusCode {
  PlusCode({
    required this.compoundCode,
    required this.globalCode,
  });

  String compoundCode;
  String globalCode;

  factory PlusCode.fromJson(Map<String, dynamic> json) => PlusCode(
    compoundCode: json["compound_code"],
    globalCode: json["global_code"],
  );
}

enum Scope { google }

final scopeValues = EnumValues({
  "GOOGLE": Scope.google
});

enum Type { mosque, placeOfWorship, pointOfInterest, establishment, touristAttraction, school }

final typeValues = EnumValues({
  "establishment": Type.establishment,
  "mosque": Type.mosque,
  "place_of_worship": Type.placeOfWorship,
  "point_of_interest": Type.pointOfInterest,
  "school": Type.school,
  "tourist_attraction": Type.touristAttraction
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

