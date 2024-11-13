import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthModel>> login({
    required String value,
    required String password
  });
  Future<Either<Failure, ProfileModel>> getProfile();
}