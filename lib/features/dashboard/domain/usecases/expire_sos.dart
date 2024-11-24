import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';

class ExpireSosUseCase {
  final DashboardRepository repository;

  ExpireSosUseCase(this.repository);

  Future<Either<Failure, void>> execute({required sosId}) {
    return repository.expireSos(sosId: sosId);
  }
}