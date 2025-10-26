import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/administration/data/models/continent.dart';
import 'package:rakhsa/modules/administration/data/models/country.dart';
import 'package:rakhsa/modules/administration/data/models/state.dart';

abstract class AdministrationRepository {
  Future<Either<Failure, ContinentModel>> getContinent();
  Future<Either<Failure, CountryModel>> getCountry({required String search});
  Future<Either<Failure, StateModel>> getStates({required int continentId});
}
