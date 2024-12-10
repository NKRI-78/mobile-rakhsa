import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';

class SosRatingUseCase {
  final DashboardRepository repository;

  SosRatingUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required sosId,
    required rating,
    required userId
  }) {
    return repository.ratingSos(
      sosId: sosId,
      rating: rating,
      userId: userId
    );
  }
}