class CountryModel {
  int status;
  bool error;
  String message;
  List<CountryData> data;

  CountryModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<CountryData>.from(json["data"].map((x) => CountryData.fromJson(x))),
  );
}

class CountryData {
  int id;
  String name;

  CountryData({
    required this.id,
    required this.name,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) => CountryData(
    id: json["id"],
    name: json["name"],
  );
}
