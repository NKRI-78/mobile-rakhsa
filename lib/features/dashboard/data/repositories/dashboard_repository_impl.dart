import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:rakhsa/features/dashboard/data/models/news.dart';
import 'package:rakhsa/features/dashboard/data/models/news_detail.dart';
import 'package:rakhsa/features/dashboard/domain/repository/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NewsModel>> getNews({
    required String type,
    required double lat,
    required double lng
  }) async {
    try {
      var result = await remoteDataSource.getNews(
        type: type, 
        lat: lat, 
        lng: lng
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NewsDetailModel>> detailNews({
    required int id,
  }) async {
    try {
      var result = await remoteDataSource.getNewsDetail(
        id: id, 
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> expireSos({required String sosId}) async {
    try {
      var result = await remoteDataSource.expireSos(sosId: sosId);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateAddress({required String address, required double lat, required double lng}) async {
    try {
      var result = await remoteDataSource.updateAddress(
        address: address,
        lat: lat, 
        lng: lng
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> ratingSos({
    required String sosId,
    required String rating
  }) async {
     try {
      var result = await remoteDataSource.ratingSos(
        sosId: sosId,
        rating: rating,
      );
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}