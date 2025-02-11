// ignore_for_file: public_member_api_docs, sort_constructors_first

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
    );
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
