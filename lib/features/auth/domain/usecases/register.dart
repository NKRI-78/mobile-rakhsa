import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthModel>> execute({
    required String fullName,
    required String emergencyContact,
    required String password,

    // required String email,
    // required String countryCode,
    // required String passportNumber,
    // required String nasionality,
    // required String placeOfBirth,
    // required String dateOfBirth,
    // required String gender,
    // required String dateOfIssue,
    // required String dateOfExpiry,
    // required String registrationNumber,
    // required String issuingAuthority,
    // required String mrzCode,
  }) {
    return repository.register(
      fullName: fullName,
      emergencyContact: emergencyContact,
      password: password,

      // email: email,
      // countryCode: countryCode,
      // passportNumber: passportNumber,
      // nasionality: nasionality,
      // placeOfBirth: placeOfBirth,
      // dateOfBirth: dateOfBirth,
      // gender: gender,
      // dateOfIssue: dateOfIssue,
      // dateOfExpiry: dateOfExpiry,
      // registrationNumber: registrationNumber,
      // issuingAuthority: issuingAuthority,
      // mrzCode: mrzCode,
    );
  }
}
