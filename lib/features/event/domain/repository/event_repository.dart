import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/event/data/models/list.dart';

abstract class EventRepository {
  Future<Either<Failure, EventModel>> list();
  Future<Either<Failure, void>> save({
    required String title,
    required String startDate,
    required String endDate,
    required int continentId,
    required int stateId,
    required String description
  });
}