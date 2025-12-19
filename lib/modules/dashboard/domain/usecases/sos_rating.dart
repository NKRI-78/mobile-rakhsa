import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

class SosRatingUseCase {
  final DashboardRepository repository;

  SosRatingUseCase(this.repository);

  Future<Either<Failure, void>> execute({required String sosId, required String rating}) {
    return repository.ratingSos(sosId: sosId, rating: rating);
  }
}
