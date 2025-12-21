import 'package:dartz/dartz.dart';

import 'package:rakhsa/core/client/errors/failure.dart';

import 'package:rakhsa/modules/dashboard/data/models/news_detail.dart';
import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

class DetailNewsUseCase {
  final DashboardRepository repository;

  DetailNewsUseCase(this.repository);

  Future<Either<Failure, NewsDetailModel>> execute({required int id}) {
    return repository.detailNews(id: id);
  }
}
