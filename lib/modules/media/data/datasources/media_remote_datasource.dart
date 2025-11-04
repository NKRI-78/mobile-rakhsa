import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rakhsa/misc/client/dio_client.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';

import 'package:rakhsa/modules/media/data/models/media.dart';

abstract class MediaRemoteDatasource {
  Future<MediaData> uploadMedia({
    required File file,
    required String folderName,
    required void Function(int count, int total)? onSendProgress,
  });
}

class MediaRemoteDataSourceImpl implements MediaRemoteDatasource {
  final DioClient client;

  MediaRemoteDataSourceImpl({required this.client});

  @override
  Future<MediaData> uploadMedia({
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
        endpoint: '/media',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return MediaData.fromJson(res.data);
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
