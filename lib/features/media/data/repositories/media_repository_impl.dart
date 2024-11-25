import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/media/data/datasources/media_remote_datasource.dart';
import 'package:rakhsa/features/media/domain/entities/media.dart';
import 'package:rakhsa/features/media/domain/repository/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource remoteDataSource;

  MediaRepositoryImpl({required this.remoteDataSource});

  @override 
  Future<Either<Failure, Media>> uploadMedia({
    required File file, 
    required String folderName
  }) async {
    try {
      var result = await remoteDataSource.uploadMedia(
        file: file, 
        folderName: folderName
      );
      return Right(result.data.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
}
