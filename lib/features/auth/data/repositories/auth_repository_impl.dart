import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';
import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rakhsa/repositories/user/model/profile.dart';

import 'package:rakhsa/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      var result = await remoteDataSource.getProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
