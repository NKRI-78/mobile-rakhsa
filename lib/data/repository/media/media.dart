import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:rakhsa/common/utils/dio.dart';

class MediaRepo {
  Response? response;
  
  Future<Response> postMedia(File file) async {
    try {
      Dio dio = DioManager.shared.getClient();
      FormData formData = FormData.fromMap({
        "folder": "images",
        "subfolder": "raksha",
        "media": await MultipartFile.fromFile(file.path, filename: basename(file.path)),
      });
      Response res = await dio.post("https://api-media.inovatiftujuh8.com/api/v1/media/upload", data: formData);
      response = res;
    } on DioException catch(e) {
      debugPrint(e.response!.data.toString());
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
    }
    return response!;
  }
  
}
