import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/administration/data/models/country.dart';

import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';

class GetCountryUseCase {
  final AdministrationRepository repository;

  GetCountryUseCase(this.repository);

  Future<Either<Failure, CountryModel>> execute({required String search}) {
    return repository.getCountry(search: search);
  }
}
