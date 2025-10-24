import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/administration/data/models/state.dart';

import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';

class GetStateUseCase {
  final AdministrationRepository repository;

  GetStateUseCase(this.repository);

  Future<Either<Failure, StateModel>> execute({required int continentId}) {
    return repository.getStates(continentId: continentId);
  }
}
