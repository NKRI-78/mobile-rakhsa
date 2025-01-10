class NearbyplaceModel {
  List<dynamic> htmlAttributions;
  String nextPageToken;
  List<Result> results;
  String status;

  NearbyplaceModel({
    required this.htmlAttributions,
    required this.nextPageToken,
    required this.results,
    required this.status,
  });

  factory NearbyplaceModel.fromJson(Map<String, dynamic> json) => NearbyplaceModel(
    htmlAttributions: List<dynamic>.from(json["html_attributions"].map((x) => x)),
    nextPageToken: json["next_page_token"],
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    status: json["status"],
  );
}

class Result {
    Geometry geometry;
    String icon;
    String iconBackgroundColor;
    String iconMaskBaseUri;
    String name;
    List<Photo>? photos;
    String placeId;
    String reference;
    String scope;
    List<String> types;
    String vicinity;
    String? businessStatus;
    OpeningHours? openingHours;
    double? rating;
    int? userRatingsTotal;
    PlusCode? plusCode;
    bool? permanentlyClosed;

    Result({
        required this.geometry,
        required this.icon,
        required this.iconBackgroundColor,
        required this.iconMaskBaseUri,
        required this.name,
        this.photos,
        required this.placeId,
        required this.reference,
        required this.scope,
        required this.types,
        required this.vicinity,
        this.businessStatus,
        this.openingHours,
        this.rating,
        this.userRatingsTotal,
        this.plusCode,
        this.permanentlyClosed,
    });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    geometry: Geometry.fromJson(json["geometry"]),
    icon: json["icon"],
    iconBackgroundColor: json["icon_background_color"] ?? "-",
    iconMaskBaseUri: json["icon_mask_base_uri"],
    name: json["name"],
    photos: json["photos"] == null ? [] : List<Photo>.from(json["photos"]!.map((x) => Photo.fromJson(x))),
    placeId: json["place_id"],
    reference: json["reference"],
    scope: json["scope"] ?? "-",
    types: List<String>.from(json["types"].map((x) => x)),
    vicinity: json["vicinity"],
    businessStatus: json["business_status"] ?? "-",
    openingHours: json["opening_hours"] == null ? null : OpeningHours.fromJson(json["opening_hours"]),
    rating: json["rating"]?.toDouble() ?? 0.0,
    userRatingsTotal: json["user_ratings_total"],
    plusCode: json["plus_code"] == null ? null : PlusCode.fromJson(json["plus_code"]),
    permanentlyClosed: json["permanently_closed"],
  );
   
}

class Geometry {
  Location location;
  Viewport viewport;

  Geometry({
    required this.location,
    required this.viewport,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    location: Location.fromJson(json["location"]),
    viewport: Viewport.fromJson(json["viewport"]),
  );
}

class Location {
  double lat;
  double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
  );
}

class Viewport {
  Location northeast;
  Location southwest;

  Viewport({
    required this.northeast,
    required this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
    northeast: Location.fromJson(json["northeast"]),
    southwest: Location.fromJson(json["southwest"]),
  );
}


class OpeningHours {
  bool openNow;

  OpeningHours({
    required this.openNow,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
    openNow: json["open_now"],
  );
}

class Photo {
  int height;
  List<String> htmlAttributions;
  String photoReference;
  int width;

  Photo({
    required this.height,
    required this.htmlAttributions,
    required this.photoReference,
    required this.width,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    height: json["height"],
    htmlAttributions: List<String>.from(json["html_attributions"].map((x) => x)),
    photoReference: json["photo_reference"],
    width: json["width"],
  );
}

class PlusCode {
  String compoundCode;
  String globalCode;

  PlusCode({
    required this.compoundCode,
    required this.globalCode,
  });

  factory PlusCode.fromJson(Map<String, dynamic> json) => PlusCode(
    compoundCode: json["compound_code"],
    globalCode: json["global_code"],
  );
}