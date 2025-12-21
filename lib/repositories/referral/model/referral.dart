// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:rakhsa/core/client/errors/errors.dart';

class ReferralData extends Equatable {
  final String keyword;
  final String serviceId;
  final String expiresAt;
  final bool hasRoamingPackage;
  final ReferralPackage? package;

  const ReferralData({
    required this.keyword,
    required this.serviceId,
    required this.expiresAt,
    required this.hasRoamingPackage,
    required this.package,
  });

  @override
  List<Object?> get props {
    return [keyword, serviceId, expiresAt, hasRoamingPackage, package];
  }

  ReferralData copyWith({
    String? keyword,
    String? serviceId,
    String? expiresAt,
    bool? hasRoamingPackage,
    ReferralPackage? package,
  }) {
    return ReferralData(
      keyword: keyword ?? this.keyword,
      serviceId: serviceId ?? this.serviceId,
      expiresAt: expiresAt ?? this.expiresAt,
      hasRoamingPackage: hasRoamingPackage ?? this.hasRoamingPackage,
      package: package ?? this.package,
    );
  }

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    try {
      return ReferralData(
        keyword: json['keyword'] ?? '',
        serviceId: json['service_id'] ?? '',
        expiresAt: json['expires_at'] ?? '',
        hasRoamingPackage: json['has_roaming_package'] ?? false,
        package: json['package'] != null
            ? ReferralPackage.fromJson(json['package'])
            : null,
      );
    } catch (e) {
      throw DataParsingException();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'service_id': serviceId,
      'expires_at': expiresAt,
      'has_roaming_package': hasRoamingPackage,
      'package': package?.toJson(),
    };
  }
}

class ReferralPackage extends Equatable {
  final int id;
  final String userId;
  final String shdcId;
  final String packageKeyword;
  final String serviceId;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReferralPackage({
    required this.id,
    required this.userId,
    required this.shdcId,
    required this.packageKeyword,
    required this.serviceId,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props {
    return [
      id,
      userId,
      shdcId,
      packageKeyword,
      serviceId,
      status,
      startAt,
      endAt,
      createdAt,
      updatedAt,
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shdc_id': shdcId,
      'package_keyword': packageKeyword,
      'service_id': serviceId,
      'status': status,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReferralPackage.fromJson(Map<String, dynamic> json) {
    try {
      return ReferralPackage(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? '',
        shdcId: json['shdc_id'] ?? '',
        packageKeyword: json['package_keyword'] ?? '',
        serviceId: json['service_id'] ?? '',
        status: json['status'] ?? '',
        startAt: DateTime.tryParse(json['start_at'] ?? '') ?? DateTime.now(),
        endAt: DateTime.tryParse(json['end_at'] ?? '') ?? DateTime.now(),
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      throw DataParsingException();
    }
  }

  ReferralPackage copyWith({
    int? id,
    String? userId,
    String? shdcId,
    String? packageKeyword,
    String? serviceId,
    String? status,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReferralPackage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shdcId: shdcId ?? this.shdcId,
      packageKeyword: packageKeyword ?? this.packageKeyword,
      serviceId: serviceId ?? this.serviceId,
      status: status ?? this.status,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
