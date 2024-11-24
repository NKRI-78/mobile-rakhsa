import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/administration/data/models/state.dart';

import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';

class GetStateUseCase {
  final AdministrationRepository repository;

  GetStateUseCase(this.repository);

  Future<Either<Failure, StateModel>> execute({required String continentId}) {
    return repository.getStates(continentId: continentId);
  }
}