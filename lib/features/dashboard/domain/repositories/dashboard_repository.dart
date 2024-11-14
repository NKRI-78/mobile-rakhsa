import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/dashboard/data/models/news.dart';

abstract class DashboardRepository {
  Future<Either<Failure, NewsModel>> getNews();
}