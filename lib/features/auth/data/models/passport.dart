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
      period: _getPeriod(map['dateOfIssue'], map['dateOfExpiry']),
    );
  }

  static String? _getPeriod(String issuingDateStr, String expiryDateStr) {
    try {
      DateTime issuingDate = DateTime.parse(issuingDateStr);
      DateTime expiryDate = DateTime.parse(expiryDateStr);
      if (expiryDate.isBefore(issuingDate)) {
        return "Paspor sudah kedaluwarsa";
      }

      final duration = expiryDate.difference(issuingDate);
      final years = duration.inDays ~/ 365;
      final months = (duration.inDays % 365) ~/ 30;
      final weeks = (duration.inDays % 365) % 30 ~/ 7;
      final days = (duration.inDays % 365) % 30 % 7;

      if (years > 0 && months > 0) {
        return "$years tahun $months bulan";
      } else if (months > 0) {
        return "$months bulan";
      } else if (weeks > 0) {
        return "$weeks minggu";
      } else {
        return "$days hari";
      }
    } catch(_) {
      return null;
    }
  }
}
