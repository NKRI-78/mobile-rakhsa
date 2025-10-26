import 'package:rakhsa/modules/media/domain/entities/media.dart';

class MediaModel {
  final int status;
  final bool error;
  final String message;
  final MediaData data;

  MediaModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: MediaData.fromJson(json["data"]),
  );
}

class MediaData {
  final String path;
  final String name;
  final String size;
  final String mimetype;

  MediaData({
    required this.path,
    required this.name,
    required this.size,
    required this.mimetype,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) => MediaData(
    path: json["path"],
    name: json["name"],
    size: json["size"],
    mimetype: json["mimetype"],
  );

  Media toEntity() {
    return Media(path: path, name: name, size: size, mimetype: mimetype);
  }
}
