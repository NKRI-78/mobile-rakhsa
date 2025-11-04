import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';

import 'package:rakhsa/modules/media/data/models/media.dart';

abstract class MediaRemoteDatasource {
  Future<MediaModel> uploadMedia({
    required File file,
    required String folderName,
    required void Function(int count, int total)? onSendProgress,
  });
}

class MediaRemoteDataSourceImpl implements MediaRemoteDatasource {
  final Dio client;

  MediaRemoteDataSourceImpl({required this.client});

  @override
  Future<MediaModel> uploadMedia({
    required File file,
    required String folderName,
    required void Function(int count, int total)? onSendProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        "media": await MultipartFile.fromFile(file.path, filename: fileName),
        "folder": folderName,
        "subfolder": "broadcast-raksha",
      });
      final res = await client.post(
        '${dotenv.env['API_MEDIA_BASE_URL'] ?? "-"}/media/upload',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return MediaModel.fromJson(res.data);
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
