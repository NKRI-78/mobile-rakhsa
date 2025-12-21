import 'package:dartz/dartz.dart';

import 'package:rakhsa/core/client/errors/failure.dart';
import 'package:rakhsa/modules/dashboard/data/models/banner.dart';

import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

class GetBannerUseCase {
  final DashboardRepository repository;

  GetBannerUseCase(this.repository);

  Future<Either<Failure, BannerModel>> execute() {
    return repository.getBanner();
  }
}
