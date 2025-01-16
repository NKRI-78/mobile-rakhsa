class AutocompleteModel {
  int status;
  bool error;
  String message;
  AutocompleteData data;

  AutocompleteModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory AutocompleteModel.fromJson(Map<String, dynamic> json) => AutocompleteModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: AutocompleteData.fromJson(json["data"]),
  );
}

class AutocompleteData {
  String provinceName;
  String cityName;
  String districtName;
  String subdistrictName;
  String tariffCode;
  int zipCode;

  AutocompleteData({
    required this.provinceName,
    required this.cityName,
    required this.districtName,
    required this.subdistrictName,
    required this.tariffCode,
    required this.zipCode,
  });

  factory AutocompleteData.fromJson(Map<String, dynamic> json) => AutocompleteData(
    provinceName: json["province_name"],
    cityName: json["city_name"],
    districtName: json["district_name"],
    subdistrictName: json["subdistrict_name"],
    tariffCode: json["tariff_code"],
    zipCode: json["zip_code"],
  );
}
