// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:rakhsa/core/client/errors/errors.dart';

class Media extends Equatable {
  const Media({
    required this.path,
    required this.name,
    required this.size,
    required this.mimetype,
  });

  final String path;
  final String name;
  final String size;
  final String mimetype;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'name': name,
      'size': size,
      'mimetype': mimetype,
    };
  }

  factory Media.fromJson(Map<String, dynamic> json) {
    try {
      return Media(
        path: json["path"],
        name: json["name"],
        size: json["size"],
        mimetype: json["mimetype"],
      );
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }

  @override
  List<Object?> get props => [path, name, size, mimetype];

  Media copyWith({String? path, String? name, String? size, String? mimetype}) {
    return Media(
      path: path ?? this.path,
      name: name ?? this.name,
      size: size ?? this.size,
      mimetype: mimetype ?? this.mimetype,
    );
  }
}
