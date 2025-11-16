import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/client/errors/code.dart';
import 'package:rakhsa/misc/client/errors/exceptions.dart';
import 'package:rakhsa/misc/client/response/response_dto.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

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

  Future<bool> get _isConnected async {
    final connectivity = await _connectivity.checkConnectivity();
    return connectivity.contains(ConnectivityResult.mobile) ||
        connectivity.contains(ConnectivityResult.wifi) ||
        connectivity.contains(ConnectivityResult.vpn);
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
      if (!await _isConnected) throw ConnectivityException();
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
      _handleError(e);
      rethrow;
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
      if (!await _isConnected) throw ConnectivityException();
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
      _handleError(e);
      rethrow;
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
      if (!await _isConnected) throw ConnectivityException();
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
      _handleError(e);
      rethrow;
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
      if (!await _isConnected) throw ConnectivityException();
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
      _handleError(e);
      rethrow;
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
      if (!await _isConnected) throw ConnectivityException();
      return _dio.delete(
        endpoint,
        cancelToken: cancelToken,
        data: data,
        options: options,
        queryParameters: queryParameters,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          throw ClientException(
            code: ErrorCode.connectionTimeout.code,
            message: ErrorCode.connectionTimeout.message(),
          );
        case DioExceptionType.receiveTimeout:
          throw ClientException(
            code: ErrorCode.receiveTimeout.code,
            message: ErrorCode.receiveTimeout.message(),
          );
        case DioExceptionType.sendTimeout:
          throw ClientException(
            code: ErrorCode.sendTimeout.code,
            message: ErrorCode.sendTimeout.message(),
          );
        case DioExceptionType.badResponse:
          throw ClientException(
            code: error.response?.statusCode ?? 400,
            message: error.response?.data['message'] ?? "-",
          );
        case DioExceptionType.cancel:
          throw ClientException(
            code: ErrorCode.cancel.code,
            message: ErrorCode.cancel.message(),
          );
        case DioExceptionType.connectionError:
          throw ClientException(
            code: ErrorCode.connectionError.code,
            message: ErrorCode.connectionError.message(),
          );
        default:
          throw ClientException(
            code: ErrorCode.unexpectedClientError.code,
            message: ErrorCode.unexpectedClientError.message(),
          );
      }
    } else if (error is ConnectivityException) {
      throw ClientException(
        code: ErrorCode.noInternetConnection.code,
        errorCode: error.errorCode,
        message: error.message,
      );
    } else {
      throw ClientException.unknown(other: error.toString());
    }
  }
}
