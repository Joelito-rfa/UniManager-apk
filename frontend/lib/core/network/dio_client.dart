import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../../config/app_config.dart';
import '../../services/storage_service.dart';
import '../errors/app_exception.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return DioClient(storageService);
});

class DioClient {
  final Dio _dio;
  final StorageService _storageService;
  bool _isRefreshing = false;

  DioClient(this._storageService)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            headers: {
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
    ]);
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshToken = await _storageService.getRefreshToken();
            if (refreshToken != null) {
              final response = await _dio.post(
                ApiConstants.refresh,
                data: {'refresh_token': refreshToken},
              );
              if (response.statusCode == 200) {
                final newToken = response.data['access_token'];
                final newRefreshToken = response.data['refresh_token'];
                await _storageService.saveToken(newToken);
                if (newRefreshToken != null) {
                  await _storageService.saveRefreshToken(newRefreshToken);
                }
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await _dio.fetch(error.requestOptions);
                handler.resolve(retryResponse);
                return;
              }
            }
            await _storageService.clearTokens();
          } catch (_) {
            await _storageService.clearTokens();
          } finally {
            _isRefreshing = false;
          }
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<File> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (response.statusCode == 200) {
        return File(savePath);
      }
      throw AppException(message: 'Le téléchargement a échoué.', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }
}
