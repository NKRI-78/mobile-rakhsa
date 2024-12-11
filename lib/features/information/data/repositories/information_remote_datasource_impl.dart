import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/information/data/datasources/kbri_remote_datasource.dart';
import 'package:rakhsa/features/information/data/models/kbri.dart';
import 'package:rakhsa/features/information/data/models/visa.dart';
import 'package:rakhsa/features/information/domain/repository/kbri_repository.dart';

class KbriRepositoryImpl implements KbriRepository {
  final KbriRemoteDataSource remoteDataSource;

  KbriRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, KbriInfoModel>> infoKbri({required String stateId}) async {
    try {
      var result = await remoteDataSource.infoKbri(
        stateId: stateId
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VisaContentModel>> infoVisa({required String stateId}) async {
    try {
      var result = await remoteDataSource.infoVisa(
        stateId: stateId
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}