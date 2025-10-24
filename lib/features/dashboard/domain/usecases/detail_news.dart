import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/features/dashboard/data/models/news_detail.dart';
import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';

class DetailNewsUseCase {
  final DashboardRepository repository;

  DetailNewsUseCase(this.repository);

  Future<Either<Failure, NewsDetailModel>> execute({required int id}) {
    return repository.detailNews(id: id);
  }
}
