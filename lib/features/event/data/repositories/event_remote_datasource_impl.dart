import 'package:dartz/dartz.dart';
import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/event/data/datasources/event_remote_datasource.dart';
import 'package:rakhsa/features/event/data/models/list.dart';

import 'package:rakhsa/features/event/domain/repository/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EventModel>> list() async {
    try {
      var result = await remoteDataSource.list();
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override 
  Future<Either<Failure, void>> save({
    required String title,
    required String startDate,
    required String endDate,
    required int continentId,
    required int stateId,
    required String description
  }) async {
    try {
      var result = await remoteDataSource.save(
        title: title, 
        startDate: startDate,
        endDate: endDate,
        continentId: continentId,
        stateId: stateId,
        description: description
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}