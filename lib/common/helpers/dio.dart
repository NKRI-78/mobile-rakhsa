import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';

class DioHelper {
  static final shared = DioHelper();

  Dio getClient() {
    Dio dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    });
    // dio.options.connectTimeout = const Duration(seconds: 5);
    // dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.options.baseUrl = RemoteDataSourceConsts.baseUrlProd;
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        String? token = await StorageHelper.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      }, onError: (DioException e, ErrorInterceptorHandler handler) async {
        if (e.error is SocketException) {
          return handler.next(e);
        }
        return handler.next(e);
      }),
    );

    return dio;
  }
}
