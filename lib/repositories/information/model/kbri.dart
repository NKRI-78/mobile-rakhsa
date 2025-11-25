import 'package:equatable/equatable.dart';
import 'package:rakhsa/misc/client/errors/exceptions/exceptions.dart';

class KBRI extends Equatable {
  final String? title;
  final String? img;
  final String? description;
  final String? lat;
  final String? lng;
  final String? address;
  final String? stateName;
  final String? emergencyCall;

  const KBRI({
    required this.title,
    required this.img,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required this.stateName,
    required this.emergencyCall,
  });

  @override
  List<Object?> get props {
    return [
      title,
      img,
      description,
      lat,
      lng,
      address,
      stateName,
      emergencyCall,
    ];
  }

  KBRI copyWith({
    String? title,
    String? img,
    String? description,
    String? lat,
    String? lng,
    String? address,
    String? stateName,
    String? emergencyCall,
  }) {
    return KBRI(
      title: title ?? this.title,
      img: img ?? this.img,
      description: description ?? this.description,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      stateName: stateName ?? this.stateName,
      emergencyCall: emergencyCall ?? this.emergencyCall,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'img': img,
      'description': description,
      'lat': lat,
      'lng': lng,
      'address': address,
      'state_name': stateName,
      'emergency_call': emergencyCall,
    };
  }

  factory KBRI.fromJson(Map<String, dynamic> map) {
    try {
      return KBRI(
        title: map['title'] ?? "-",
        img: map['img'] ?? "-",
        description: map['description'] ?? "-",
        lat: map['lat'] ?? "-",
        lng: map['lng'] ?? "-",
        address: map['address'] ?? "-",
        stateName: map['state_name'] ?? "-",
        emergencyCall: map['emergency_call'] ?? "-",
      );
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }
}
