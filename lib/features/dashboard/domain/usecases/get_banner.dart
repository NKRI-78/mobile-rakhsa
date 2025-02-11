import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/dashboard/data/models/banner.dart';

import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';

class GetBannerUseCase {
  final DashboardRepository repository;

  GetBannerUseCase(this.repository);

  Future<Either<Failure, BannerModel>> execute() {
    return repository.getBanner();
  }
}