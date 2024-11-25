import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/administration/data/models/country.dart';

import 'package:rakhsa/features/administration/domain/repository/administration_repository.dart';

class GetCountryUseCase {
  final AdministrationRepository repository;

  GetCountryUseCase(this.repository);

  Future<Either<Failure, CountryModel>> execute() {
    return repository.getCountry();
  }
}