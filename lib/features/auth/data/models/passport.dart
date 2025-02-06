// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

class Passport {
  final String type;
  final String countryCode;
  final String? passportNumber;
  final String? fullName;
  final String nationality;
  final String? dateOfBirth;
  final String? gender;
  final String? placeOfBirth;
  final String? dateOfIssue;
  final String? dateOfExpiry;
  final String? registrationNumber;
  final String? issuingAuthority;
  final String? mrzCode;
  final String? period;

  Passport({
    this.type = 'P',
    this.countryCode = 'IDN',
    required this.passportNumber,
    required this.fullName,
    this.nationality = 'INDONESIA',
    required this.dateOfBirth,
    required this.gender,
    required this.placeOfBirth,
    required this.dateOfIssue,
    required this.dateOfExpiry,
    required this.registrationNumber,
    required this.issuingAuthority,
    required this.mrzCode,
    required this.period,
  });

  factory Passport.fromMap(Map<String, dynamic> map) {
    return Passport(
      passportNumber: map['passportNumber'],
      fullName: map['fullName'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      placeOfBirth: map['placeOfBirth'],
      dateOfIssue: map['dateOfIssue'],
      dateOfExpiry: map['dateOfExpiry'],
      registrationNumber: map['registrationNumber'],
      issuingAuthority: map['issuingAuthority'],
      mrzCode: map['mrzCode'],
      period: _getPeriod(map['dateOfExpiry']),
    );
  }

  static String? _getPeriod(String expiryDateStr) {
    try {
      DateTime now = DateTime.now();
      DateTime expiryDate = DateTime.parse(expiryDateStr);

      log('expiry date: ${expiryDate.toString()}');
      log('expiry date str: $expiryDateStr');

      if (expiryDate.isBefore(now)) {
        return "Paspor sudah kadaluwarsa";
      }

      final totalDays = expiryDate.difference(now).inDays;
      final years = totalDays ~/ 365;
      final remainingDaysAfterYears = totalDays % 365;
      final months = remainingDaysAfterYears ~/ 30;
      final remainingDaysAfterMonths = remainingDaysAfterYears % 30;
      final weeks = remainingDaysAfterMonths ~/ 7;
      final days = remainingDaysAfterMonths % 7;

      if (years > 0 && months > 0) {
        return "$years tahun $months bulan";
      } else if (years > 0) {
        return "$years tahun";
      } else if (months > 0) {
        return "$months bulan";
      } else if (weeks > 0) {
        return "$weeks minggu";
      } else {
        return "$days hari";
      }
    } catch (_) {
      return null;
    }
  }
}

class PassportDataExtraction {
  final bool errorScanning;
  final Passport? passport;
  final String serviceTier;
  final LimitUsagePassportDataExtraction limit;

  PassportDataExtraction({
    required this.errorScanning, 
    required this.passport, 
    required this.serviceTier, 
    required this.limit,
  });

  factory PassportDataExtraction.fromMap(Map<String, dynamic> data){
    return PassportDataExtraction(
      passport: Passport.fromMap(data['result']),
      errorScanning: data['error'],
      serviceTier: data['service_tier'],
      limit: LimitUsagePassportDataExtraction.fromMap(data['usage'])
    );
  }
}

class LimitUsagePassportDataExtraction {
  final int promtTokens;
  final int completionTokens;
  final int totalTokens;

  LimitUsagePassportDataExtraction({
    required this.promtTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory LimitUsagePassportDataExtraction.fromMap(Map<String, dynamic> data) {
    return LimitUsagePassportDataExtraction(
      promtTokens: data['prompt_tokens'],
      completionTokens: data['completion_tokens'],
      totalTokens: data['total_tokens'],
    );
  }
}
