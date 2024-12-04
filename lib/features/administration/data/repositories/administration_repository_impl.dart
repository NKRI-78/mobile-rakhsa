import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/administration/data/datasources/administration_remote_data_source.dart';
import 'package:rakhsa/features/administration/data/models/continent.dart';
import 'package:rakhsa/features/administration/data/models/country.dart';
import 'package:rakhsa/features/administration/data/models/state.dart';

import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';

class AdministrationRepositoryImpl implements AdministrationRepository {
  final AdministrationRemoteDataSource remoteDataSource;

  AdministrationRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, ContinentModel>> getContinent({required int continentId}) async {
    try {
      var result = await remoteDataSource.getContinent(continentId: continentId);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CountryModel>> getCountry({
    required String search
  }) async {
    try {
      var result = await remoteDataSource.getCountry(search: search);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StateModel>> getStates({
    required int continentId
  }) async {
    try {
      var result = await remoteDataSource.getStates(continentId: continentId);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}