import 'package:equatable/equatable.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';

class GeoNode extends Equatable {
  final int id;
  final String name;

  const GeoNode({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];

  GeoNode copyWith({int? id, String? name}) {
    return GeoNode(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory GeoNode.fromJson(Map<String, dynamic> map) {
    try {
      return GeoNode(id: map['id'] ?? 0, name: map['name'] ?? "-");
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }
}
