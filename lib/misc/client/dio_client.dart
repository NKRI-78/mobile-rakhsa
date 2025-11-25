import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/misc/client/response/response_dto.dart';
import 'package:rakhsa/service/storage/storage.dart';

typedef ReceivedProgressCallback = void Function(int received, int total);
typedef SendProgressCallback = void Function(int count, int total);

class DioClient {
  final Dio _dio;
  final Connectivity _connectivity;

  DioClient(this._connectivity)
    : _dio = Dio(
        BaseOptions(
          baseUrl: BuildConfig.instance.apiBaseUrl ?? "",
          connectTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(minutes: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final publicEndpoints = [
            "/auth/login",
            "/auth/register-member",
            "/media",
            "/admin/toggle/feature",
          ];
          final public = publicEndpoints.contains(options.path);
          if (!public) {
            final session = StorageHelper.session;
            if (session != null) {
              options.headers['Authorization'] = 'Bearer ${session.token}';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Dio createNewInstance({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 60),
    Duration receiveTimeout = const Duration(seconds: 60),
    Duration sendTimeout = const Duration(minutes: 5),
    Map<String, dynamic>? headers,
    bool withLogger = true,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (headers != null) ...headers,
        },
      ),
    );

    if (withLogger) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          enabled: kDebugMode,
        ),
      );
    }

    return dio;
  }

  Future<bool> get hasInternet {
    return _connectivity
        .checkConnectivity()
        .then((conns) {
          return conns.contains(ConnectivityResult.mobile) ||
              conns.contains(ConnectivityResult.wifi) ||
              conns.contains(ConnectivityResult.vpn);
        })
        .catchError((e, st) => false);
  }

  Future<ResponseDto<T>> get<T>({
    required String endpoint,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    ReceivedProgressCallback? onReceiveProgress,
  }) async {
    try {
      if (!await hasInternet) throw NetworkException.noInternetConnection();
      final res = await _dio.get(
        endpoint,
        data: data,
        options: options,
        cancelToken: cancelToken,
        queryParameters: queryParams,
        onReceiveProgress: onReceiveProgress,
      );
      return ResponseDto.fromJson(res.data);
    } catch (e) {
      throw errorMapper(e);
    }
  }

  Future<ResponseDto<T>> post<T>({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    SendProgressCallback? onSendProgress,
    ReceivedProgressCallback? onReceiveProgress,
  }) async {
    try {
      if (!await hasInternet) throw NetworkException.noInternetConnection();
      final res = await _dio.post(
        endpoint,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      return ResponseDto.fromJson(res.data);
    } catch (e) {
      throw errorMapper(e);
    }
  }

  Future<Response<T>> put<T>({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    SendProgressCallback? onSendProgress,
    ReceivedProgressCallback? onReceiveProgress,
  }) async {
    try {
      if (!await hasInternet) throw NetworkException.noInternetConnection();
      return _dio.put(
        endpoint,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw errorMapper(e);
    }
  }

  Future<Response<dynamic>> download({
    required String url,
    required String savePath,
    ReceivedProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    try {
      if (!await hasInternet) throw NetworkException.noInternetConnection();
      final response = await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        data: data,
        deleteOnError: deleteOnError,
        fileAccessMode: fileAccessMode,
        lengthHeader: lengthHeader,
        onReceiveProgress: onReceiveProgress,
        options: options,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      throw errorMapper(e);
    }
  }

  Future<Response<T>> delete<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Object? data,
    Options? options,
  }) async {
    try {
      if (!await hasInternet) throw NetworkException.noInternetConnection();
      return _dio.delete(
        endpoint,
        cancelToken: cancelToken,
        data: data,
        options: options,
        queryParameters: queryParameters,
      );
    } catch (e) {
      throw errorMapper(e);
    }
  }

  NetworkException errorMapper(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 400;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return NetworkException(
            errorType: NetworkError.connectionTimeout,
            message: 'Koneksi terlalu lama. Silakan coba lagi.',
            original: error,
            statusCode: statusCode,
          );
        case DioExceptionType.receiveTimeout:
          return NetworkException(
            errorType: NetworkError.receiveTimeout,
            message: 'Server membutuhkan waktu terlalu lama untuk merespons.',
            original: error,
            statusCode: statusCode,
          );
        case DioExceptionType.sendTimeout:
          return NetworkException(
            errorType: NetworkError.sendTimeout,
            message:
                'Pengiriman data ke server melebihi batas waktu. Coba ulangi.',
            original: error,
            statusCode: statusCode,
          );
        case DioExceptionType.cancel:
          return NetworkException(
            errorType: NetworkError.cancel,
            message: 'Permintaan dibatalkan. Silakan coba kembali.',
            original: error,
            statusCode: statusCode,
          );
        case DioExceptionType.connectionError:
          return NetworkException(
            errorType: NetworkError.connectionError,
            message:
                'Server tidak dapat dijangkau. Periksa koneksi Anda lalu coba lagi.',
            original: error,
            statusCode: statusCode,
          );
        case DioExceptionType.badResponse:
          final body = error.response?.data;
          final msg = _extractMessageFromBody(body) ?? error.message;
          return NetworkException(
            errorType: NetworkError.badResponse,
            statusCode: statusCode,
            body: body,
            message: msg,
            original: error,
          );
        default:
          return NetworkException.unknown(error, statusCode);
      }
    } else {
      return NetworkException.unknown(error);
    }
  }

  String? _extractMessageFromBody(dynamic body) {
    try {
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return null;
  }
}
