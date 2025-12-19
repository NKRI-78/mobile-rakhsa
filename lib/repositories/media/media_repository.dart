import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/misc/client/response/response_dto.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/repositories/media/model/media.dart';
import 'package:rakhsa/service/storage/storage.dart';

class MediaRepository {
  MediaRepository(this._client);

  final DioClient _client;

  Dio get _mediaClient {
    final token = StorageHelper.session?.token;
    return _client.createNewInstance(
      baseUrl: dotenv.env['API_MEDIA_BASE_URL'] ?? "",
      headers: {'Authorization': 'Bearer $token'},
      sendTimeout: Duration(minutes: 6),
    );
  }

  Future<Media> sendSosRecordVideo({
    required File video,
    required void Function(int count, int total) onSendProgress,
  }) async {
    try {
      if (!await _client.hasInternet) {
        throw NetworkException.noInternetConnection();
      }

      final formData = FormData.fromMap({
        "folder": "videos",
        "subfolder": "broadcast-raksha",
        "media": await MultipartFile.fromFile(
          video.path,
          filename: video.filename,
        ),
      });
      final res = await _mediaClient.post(
        "/media/upload",
        data: formData,
        onSendProgress: onSendProgress,
      );
      final dto = ResponseDto.fromJson(res.data);
      return Media.fromJson(dto.data);
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    } catch (e) {
      throw _client.errorMapper(e);
    }
  }
}
