import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/administration/data/models/continent.dart';
import 'package:rakhsa/modules/administration/domain/repository/administration_repository.dart';

class GetContinentUseCase {
  final AdministrationRepository repository;

  GetContinentUseCase(this.repository);

  Future<Either<Failure, ContinentModel>> execute() {
    return repository.getContinent();
  }
}
