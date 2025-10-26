import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';
import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/information/data/datasources/kbri_remote_datasource.dart';
import 'package:rakhsa/modules/information/data/models/kbri.dart';
import 'package:rakhsa/modules/information/data/models/passport.dart';
import 'package:rakhsa/modules/information/data/models/visa.dart';
import 'package:rakhsa/modules/information/domain/repository/kbri_repository.dart';

class KbriRepositoryImpl implements KbriRepository {
  final KbriRemoteDataSource remoteDataSource;

  KbriRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, KbriInfoModel>> infoKbriStateId({
    required String stateId,
  }) async {
    try {
      var result = await remoteDataSource.infoKbriStateId(stateId: stateId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KbriInfoModel>> infoKbriStateName({
    required String stateName,
  }) async {
    try {
      var result = await remoteDataSource.infoKbriStateName(
        stateName: stateName,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VisaContentModel>> infoVisa({
    required String stateId,
  }) async {
    try {
      var result = await remoteDataSource.infoVisa(stateId: stateId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PassportContentModel>> infoPassport({
    required String stateId,
  }) async {
    try {
      var result = await remoteDataSource.infoPassport(stateId: stateId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
