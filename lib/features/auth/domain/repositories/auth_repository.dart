import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';
import 'package:rakhsa/features/auth/data/models/profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthModel>> login({
    required String value,
    required String password
  });
  Future<Either<Failure, void>> forgotPassword({
    required String email,
    required String oldPassword,
    required String newPassword
  });
  Future<Either<Failure, void>> updateIsLoggedIn({
    required String userId,
    required String type
  });
  Future<Either<Failure, ProfileModel>> getProfile();
  Future<Either<Failure, void>> updateProfile({
    required String avatar
  });
  Future<Either<Failure, AuthModel>> register({
    required String countryCode,
    required String passportNumber,
    required String fullName,
    required String nasionality,
    required String placeOfBirth,
    required String dateOfBirth,
    required String gender,
    required String dateOfIssue,
    required String dateOfExpiry,
    required String registrationNumber,
    required String issuingAuthority,
    required String mrzCode,
    required String email,
    required String emergencyContact,
    required String password
  });
  Future<Either<Failure, AuthModel>> verifyOtp({
    required String email,
    required String otp,
  });
  Future<Either<Failure, void>> resendOtp({
    required String email,
  });
  Future<Either<Failure, PassportDataExtraction>> registerPassport({
    required String imagePath,
  });
  Future<Either<Failure, void>> checkRegisterStatus({
    required String passport,
    required String noReg,
  });
}