import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';
import 'package:rakhsa/modules/media/domain/entities/media.dart';

abstract class MediaRepository {
  Future<Either<Failure, Media>> uploadMedia({
    required File file,
    required String folderName,
    required void Function(int count, int total)? onSendProgress,
  });
}
