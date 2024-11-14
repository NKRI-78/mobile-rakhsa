import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/media/domain/entities/media.dart';

abstract class MediaRepository {

  Future<Either<Failure, Media>> uploadMedia({
    required File file,
    required String folderName,
  });
}