
class StateModel {
  int status;
  bool error;
  String message;
  List<StateData> data;

  StateModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<StateData>.from(json["data"].map((x) => StateData.fromJson(x))),
  );
}

class StateData {
  String name;

  StateData({
    required this.name,
  });

  factory StateData.fromJson(Map<String, dynamic> json) => StateData(
    name: json["name"],
  );
}
