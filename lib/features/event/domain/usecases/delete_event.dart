import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/event/domain/repository/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository repository;

  DeleteEventUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required int id
  }) {
    return repository.delete(
      id: id
    );  
  }
}