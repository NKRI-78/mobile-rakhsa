import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/event/domain/repository/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository repository;

  UpdateEventUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required int id,
    required String title,
    required String startDate,
    required String endDate,
    required int continentId,
    required int stateId,
    required String description
  }) {
    return repository.update(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      continentId: continentId,
      stateId: stateId,
      description: description
    );  
  }
}