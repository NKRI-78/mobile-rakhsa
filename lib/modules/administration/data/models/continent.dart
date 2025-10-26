class ContinentModel {
  final int status;
  final bool error;
  final String message;
  final List<CountryData> data;

  ContinentModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory ContinentModel.fromJson(Map<String, dynamic> json) {
    return ContinentModel(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      data: List<CountryData>.from(json['data'].map((item) => CountryData.fromJson(item))),
    );
  }
}

class CountryData {
  final int id;
  final String name;

  CountryData({
    required this.id,
    required this.name,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      id: json['id'],
      name: json['name'],
    );
  }
}
