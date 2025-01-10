import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/nearme/data/datasources/nearme_remote_data_source.dart';
import 'package:rakhsa/features/nearme/data/models/nearme.dart';
import 'package:rakhsa/features/nearme/domain/repository/nearme_repository.dart';

class NearmeRepositoryImpl implements NearmeRepository {
  final NearmeRemoteDataSource remoteDataSource;

  NearmeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NearbyplaceModel>> getNearme({
    required double currentLat, 
    required double currentLng,
    required String type,
  }) async {
    try {
      var result = await remoteDataSource.getNearme(
        currentLat: currentLat,
        currentLng: currentLng,
        type: type, 
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}