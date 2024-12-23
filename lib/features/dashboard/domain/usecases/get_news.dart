import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/dashboard/data/models/news.dart';
import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';

class GetNewsUseCase {
  final DashboardRepository repository;

  GetNewsUseCase(this.repository);

  Future<Either<Failure, NewsModel>> execute({
    required String type,
    required double lat, 
    required double lng
  }) {
    return repository.getNews(
      type: type,
      lat: lat, 
      lng: lng
    );
  }
}