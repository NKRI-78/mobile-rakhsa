import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/media/domain/entities/media.dart';
import 'package:rakhsa/features/media/domain/repository/media_repository.dart';

class UploadMediaUseCase {
  final MediaRepository repository;

  UploadMediaUseCase(this.repository);

  Future<Either<Failure, Media>> execute({
    required File file,
    required String folderName
  }) async {
    return repository.uploadMedia(file: file, folderName: folderName);
  }
}