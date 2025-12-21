import 'package:equatable/equatable.dart';
import 'package:rakhsa/core/client/errors/exceptions/data_parsing_exception.dart';

class ImageBanner extends Equatable {
  final int id;
  final String? title;
  final String? link;
  final String? imageUrl;

  const ImageBanner({required this.id, this.title, this.link, this.imageUrl});

  @override
  List<Object?> get props => [id, title, link, imageUrl];

  ImageBanner copyWith({
    int? id,
    String? title,
    String? link,
    String? imageUrl,
  }) {
    return ImageBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'link': link, 'image_url': imageUrl};
  }

  factory ImageBanner.fromJson(Map<String, dynamic> json) {
    try {
      return ImageBanner(
        id: json['id'] ?? 0,
        title: json['title'],
        link: json['link'],
        imageUrl: json['image_url'],
      );
    } catch (e) {
      throw DataParsingException();
    }
  }
}
