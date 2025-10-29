import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';
import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/media/data/datasources/media_remote_datasource.dart';
import 'package:rakhsa/modules/media/domain/entities/media.dart';
import 'package:rakhsa/modules/media/domain/repository/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource remoteDataSource;

  MediaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Media>> uploadMedia({
    required File file,
    required String folderName,
    required void Function(int count, int total)? onSendProgress,
  }) async {
    try {
      var result = await remoteDataSource.uploadMedia(
        file: file,
        folderName: folderName,
        onSendProgress: onSendProgress,
      );
      return Right(result.data.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
