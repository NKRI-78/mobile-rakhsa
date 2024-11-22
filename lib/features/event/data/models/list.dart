class EventModel {
  int status;
  bool error;
  String message;
  List<EventData> data;

  EventModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<EventData>.from(json["data"].map((x) => EventData.fromJson(x))),
  );
}

class EventData {
  int id;
  String title;
  String description;
  String state;
  String continent;
  String startDate;
  String endDate;
  EventUser user;

  EventData({
    required this.id,
    required this.title,
    required this.description,
    required this.state,
    required this.continent,
    required this.startDate,
    required this.endDate,
    required this.user,
  });

  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    state: json["state"],
    continent: json["continent"],
    startDate: json["start_date"],
    endDate: json["end_date"],
    user: EventUser.fromJson(json["user"]),
  );
}

class EventUser {
  String id;
  String name;

  EventUser({
    required this.id,
    required this.name,
  });

  factory EventUser.fromJson(Map<String, dynamic> json) => EventUser(
    id: json["id"],
    name: json["name"],
  );
}
