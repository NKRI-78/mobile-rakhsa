import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/domain/repository/event_repository.dart';

class ListEventUseCase {
  final EventRepository repository;

  ListEventUseCase(this.repository);

  Future<Either<Failure, EventModel>> execute() {
    return repository.list();
  }
}