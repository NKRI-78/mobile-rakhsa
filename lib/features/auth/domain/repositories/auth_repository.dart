import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';
import 'package:rakhsa/repositories/user/model/profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, ProfileModel>> getProfile();
}
