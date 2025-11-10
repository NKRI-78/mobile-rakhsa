import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';

class MediaRepo {
  Response? response;
  final Dio dio;

  MediaRepo({required this.dio});

  Future<Response> postMedia(File file) async {
    try {
      FormData formData = FormData.fromMap({
        "folder": "images",
        "subfolder": "raksha",
        "media": await MultipartFile.fromFile(
          file.path,
          filename: basename(file.path),
        ),
      });
      Response res = await dio.post(
        "${dotenv.env['API_MEDIA_BASE_URL'] ?? "-"}/media/upload",
        data: formData,
      );
      response = res;
    } on DioException catch (e) {
      debugPrint(e.response!.data.toString());
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
    return response!;
  }
}
