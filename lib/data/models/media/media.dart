import 'package:equatable/equatable.dart';

class MediaModel {
  MediaModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  int? status;
  bool? error;
  String? message;
  MediaData? data;

  factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
    status: json["status"] ?? 0,
    error: json["error"] ?? true,
    message: json["message"] ?? "null",
    data: MediaData.fromJson(json["data"]),
  );
}

class MediaData extends Equatable {
  const MediaData({
    this.path,
    this.name,
    this.size,
    this.mimetype,
  });

  final String? path;
  final String? name;
  final String? size;
  final String? mimetype;

  factory MediaData.fromJson(Map<String, dynamic> json) => MediaData(
    path: json["path"],
    name: json["name"],
    size: json["size"],
    mimetype: json["mimetype"] ?? "null",
  );

  @override
  List<Object?> get props => [
    path,
    name,
    size,
    mimetype,
  ];
}
