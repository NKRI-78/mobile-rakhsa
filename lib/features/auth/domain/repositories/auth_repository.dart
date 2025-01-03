import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthModel>> login({
    required String value,
    required String password
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
    required String fullname,
    required String email,
    required String phone,
    required String passport,
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
}