import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/event/domain/repository/event_repository.dart';

class SaveEventUseCase {
  final EventRepository repository;

  SaveEventUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String title,
    required String startDate,
    required String endDate,
    required int continentId,
    required int stateId,
    required String description
  }) {
    return repository.save(
      title: title,
      startDate: startDate,
      endDate: endDate, 
      continentId: continentId,
      stateId: stateId,
      description: description
    );
  }
}