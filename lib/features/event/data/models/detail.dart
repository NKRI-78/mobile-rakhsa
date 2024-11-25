class EventDetailModel {
  int status;
  bool error;
  String message;
  EventDetailData data;

  EventDetailModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) => EventDetailModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: EventDetailData.fromJson(json["data"]),
  );
}

class EventDetailData {
  int id;
  String title;
  String description;
  String state;
  String continent;
  String startDay;
  String endDay;
  String startDate;
  String endDate;
  User user;

  EventDetailData({
    required this.id,
    required this.title,
    required this.description,
    required this.state,
    required this.continent,
    required this.startDay,
    required this.endDay,
    required this.startDate,
    required this.endDate,
    required this.user,
  });

  factory EventDetailData.fromJson(Map<String, dynamic> json) => EventDetailData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    state: json["state"],
    continent: json["continent"],
    startDay: json["start_day"],
    endDay: json["end_day"],
    startDate: json["start_date"],
    endDate: json["end_date"],
    user: User.fromJson(json["user"]),
  );
}

class User {
  String id;
  String name;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
  );
}
