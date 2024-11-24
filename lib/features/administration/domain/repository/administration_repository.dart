import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/administration/data/models/continent.dart';

abstract class AdministrationRepository {
  Future<Either<Failure, ContinentModel>> getContinent();
}