class SocmedMediaEntity {
  int id;
  String name;
  String icon;
  String link;
  App app;

  SocmedMediaEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.link,
    required this.app,
  });

  factory SocmedMediaEntity.fromJson(Map<String, dynamic> json) => SocmedMediaEntity(
    id: json["id"],
    name: json["name"],
    icon: json["icon"],
    link: json["link"],
    app: App.fromJson(json["app"]),
  );
}

class App {
  String id;
  String name;

  App({
    required this.id,
    required this.name,
  });

  factory App.fromJson(Map<String, dynamic> json) => App(
    id: json["id"],
    name: json["name"],
  );
}