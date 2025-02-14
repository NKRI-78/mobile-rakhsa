import 'dart:io';

import 'package:dio/dio.dart';

import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/media/data/models/media.dart';

abstract class MediaRemoteDatasource {
  Future<MediaModel> uploadMedia({
    required File file,
    required String folderName,
  });
}

class MediaRemoteDataSourceImpl implements MediaRemoteDatasource {
  final Dio client;

  MediaRemoteDataSourceImpl({required this.client});

  @override
  Future<MediaModel> uploadMedia({
    required File file,
    required String folderName,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        "media": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "folder": folderName,
        "subfolder": "broadcast-raksha"
      });
      final res = await client.post('https://api-media.inovatiftujuh8.com/api/v1/media/upload',
        data: formData
      );
      Map<String, dynamic> data = res.data;
      return MediaModel.fromJson(data);
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
