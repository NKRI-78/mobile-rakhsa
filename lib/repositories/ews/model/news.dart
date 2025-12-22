import 'package:equatable/equatable.dart';
import 'package:rakhsa/core/client/errors/errors.dart';

class News extends Equatable {
  final int id;
  final String? title;
  final String? imageUrl;
  final String? description;
  final String? addressLocation;
  final String? type;

  const News({
    required this.id,
    this.title,
    this.imageUrl,
    this.description,
    this.addressLocation,
    this.type,
  });

  @override
  List<Object?> get props {
    return [id, title, imageUrl, description, addressLocation, type];
  }

  News copyWith({
    int? id,
    String? title,
    String? imageUrl,
    String? description,
    String? addressLocation,
    String? type,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      addressLocation: addressLocation ?? this.addressLocation,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'img': imageUrl,
      'desc': description,
      'location': addressLocation,
      'type': type,
    };
  }

  factory News.fromJson(Map<String, dynamic> map) {
    try {
      return News(
        id: map['id'],
        title: map['title'],
        imageUrl: map['img'],
        description: map['desc'],
        addressLocation: map['location'],
        type: map['type'],
      );
    } catch (e) {
      throw DataParsingException();
    }
  }
}
