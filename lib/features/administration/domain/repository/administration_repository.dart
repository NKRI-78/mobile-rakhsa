import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/administration/data/models/continent.dart';
import 'package:rakhsa/features/administration/data/models/state.dart';

abstract class AdministrationRepository {
  Future<Either<Failure, ContinentModel>> getContinent();
  Future<Either<Failure, StateModel>> getStates({
    required int continentId
  });
}