import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/dashboard/data/models/banner.dart';
import 'package:rakhsa/modules/dashboard/data/models/news.dart';
import 'package:rakhsa/modules/dashboard/data/models/news_detail.dart';

abstract class DashboardRepository {
  Future<Either<Failure, BannerModel>> getBanner();
  Future<Either<Failure, NewsModel>> getNews({
    required double lat,
    required double lng,
    required String state,
  });
  Future<Either<Failure, NewsDetailModel>> detailNews({required int id});
  Future<Either<Failure, void>> userTrack({
    required String address,
    required double lat,
    required double lng,
  });
  Future<Either<Failure, void>> updateAddress({
    required String address,
    required String state,
    required double lat,
    required double lng,
  });
  Future<Either<Failure, void>> ratingSos({
    required String sosId,
    required String rating,
  });
}
