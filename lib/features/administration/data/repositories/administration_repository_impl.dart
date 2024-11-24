import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/administration/data/datasources/administration_remote_data_source.dart';
import 'package:rakhsa/features/administration/data/models/continent.dart';

import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';

class AdministrationRepositoryImpl implements AdministrationRepository {
  final AdministrationRemoteDataSource remoteDataSource;

  AdministrationRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, ContinentModel>> getContinent() async {
    try {
      var result = await remoteDataSource.getContinent();
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}