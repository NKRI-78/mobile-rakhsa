import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/dashboard/data/models/news.dart';
import 'package:rakhsa/features/dashboard/data/models/news_detail.dart';

abstract class DashboardRepository {
  Future<Either<Failure, NewsModel>> getNews({
    required String type,
    required double lat, 
    required double lng
  });
  Future<Either<Failure, NewsDetailModel>> detailNews({
    required int id
  });
   Future<Either<Failure, void>> userTrack({
    required String address, 
    required double lat, 
    required double lng
  });
  Future<Either<Failure, void>> updateAddress({
    required String address, 
    required String state,
    required double lat, 
    required double lng
  });
  Future<Either<Failure, void>> expireSos({required String sosId});
  Future<Either<Failure, void>> ratingSos({
    required String sosId,
    required String rating
  });
}