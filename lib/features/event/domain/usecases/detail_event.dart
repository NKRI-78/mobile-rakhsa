import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/event/data/models/detail.dart';

import 'package:rakhsa/features/event/domain/repository/event_repository.dart';

class DetailEventUseCase {
  final EventRepository repository;

  DetailEventUseCase(this.repository);

  Future<Either<Failure, EventDetailModel>> execute({
    required int id
  }) {
    return repository.detail(
      id: id
    );  
  }
}