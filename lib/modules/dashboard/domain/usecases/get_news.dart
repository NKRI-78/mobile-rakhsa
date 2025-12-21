import 'package:dartz/dartz.dart';

import 'package:rakhsa/core/client/errors/failure.dart';

import 'package:rakhsa/modules/dashboard/data/models/news.dart';
import 'package:rakhsa/modules/dashboard/domain/repository/dashboard_repository.dart';

class GetNewsUseCase {
  final DashboardRepository repository;

  GetNewsUseCase(this.repository);

  Future<Either<Failure, NewsModel>> execute({
    required String state,
    required double lat,
    required double lng,
  }) {
    return repository.getNews(state: state, lat: lat, lng: lng);
  }
}
