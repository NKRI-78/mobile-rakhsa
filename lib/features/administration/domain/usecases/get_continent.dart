import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/administration/data/models/continent.dart';
import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';

class GetContinentUseCase {
  final AdministrationRepository repository;

  GetContinentUseCase(this.repository);

  Future<Either<Failure, ContinentModel>> execute({
    required int continentId
  }) {
    return repository.getContinent(
      continentId: continentId
    );
  }
}