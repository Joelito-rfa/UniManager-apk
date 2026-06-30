import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../connectivity/connectivity_service.dart';
import '../cache/cache_service.dart';
import '../constants/api_constants.dart';
import '../../config/app_config.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storageService = ref.read(storageServiceProvider);
  final connectivityService = ref.read(connectivityServiceProvider);
  final cacheService = ref.read(cacheServiceProvider);
  return DioClient(
    storageService,
    connectivityService,
    cacheService,
    ref,
  );
});

class DioClient {
  late final Dio _dio;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;
  final CacheService _cacheService;
  final Ref _ref;
  final Logger _logger = Logger();
  bool _isRefreshing = false;

  DioClient(
    this._storageService,
    this._connectivityService,
    this._cacheService,
    this._ref,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      _retryInterceptor(),
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
        if (error.response?.statusCode != 401 || _isRefreshing) {
          handler.next(error);
          return;
        }

        _isRefreshing = true;
        try {
          final refreshed = await _attemptRefresh();
          if (refreshed) {
            final newToken = await _storageService.getToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await _dio.fetch(error.requestOptions);
            handler.resolve(retryResponse);
            return;
          }
          await _handleAuthFailure();
        } catch (e) {
          _logger.e('Token refresh failed', error: e);
          await _handleAuthFailure();
        } finally {
          _isRefreshing = false;
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          final retries = _getRetryCount(error.requestOptions);
          if (retries < AppConfig.maxRetries) {
            await Future.delayed(AppConfig.retryDelay * (retries + 1));
            final options = error.requestOptions;
            options.headers['X-Retry-Count'] = '${retries + 1}';
            try {
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (e) {
              handler.next(e as DioException);
              return;
            }
          }
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i('${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('${error.type} ${error.message}');
        handler.next(error);
      },
    );
  }

  bool _shouldRetry(DioException error) {
    if (error.response != null && error.response!.statusCode! < 500) return false;
    if (error.type == DioExceptionType.cancel) return false;
    if (error.type == DioExceptionType.badResponse && error.response?.statusCode == 401) return false;
    return true;
  }

  int _getRetryCount(RequestOptions options) {
    final count = options.headers['X-Retry-Count'] as String?;
    return count != null ? int.tryParse(count) ?? 0 : 0;
  }

  Future<bool> _attemptRefresh() async {
    try {
      final currentToken = await _storageService.getToken();
      if (currentToken == null) return false;

      final refreshToken = await _storageService.getRefreshToken();
      final response = await Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      )).post(
        ApiConstants.refresh,
        data: refreshToken != null
            ? {'refresh_token': refreshToken}
            : {},
        options: Options(headers: {
          'Authorization': 'Bearer $currentToken',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final newToken = response.data['access_token'] as String;
        await _storageService.saveToken(newToken);
        if (response.data['refresh_token'] != null) {
          await _storageService.saveRefreshToken(response.data['refresh_token'] as String);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleAuthFailure() async {
    await _storageService.clearTokens();
    _ref.read(authProvider.notifier).forceLogout();
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool useCache = false,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    final cacheKey = 'GET:$path${queryParameters != null ? jsonEncode(queryParameters) : ''}';

    if (useCache && !forceRefresh) {
      final cached = _cacheService.getCachedResponse(cacheKey);
      if (cached != null) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: jsonDecode(cached),
          statusCode: 200,
        );
      }
    }

    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      final cached = _cacheService.getCachedResponse(cacheKey);
      if (cached != null) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: jsonDecode(cached),
          statusCode: 200,
        );
      }
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Pas de connexion internet',
        type: DioExceptionType.connectionError,
      );
    }

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      if (useCache && response.statusCode == 200) {
        _cacheService.cacheResponse(cacheKey, jsonEncode(response.data));
      }

      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        final cached = _cacheService.getCachedResponse(cacheKey);
        if (cached != null) {
          return Response(
            requestOptions: RequestOptions(path: path),
            data: jsonDecode(cached),
            statusCode: 200,
          );
        }
      }
      rethrow;
    }
  }

  Future<Response> getPaginated(
    String path, {
    int page = 1,
    int perPage = 20,
    Map<String, dynamic>? filters,
    CancelToken? cancelToken,
  }) async {
    return get(
      path,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (filters != null) ...filters,
      },
      cancelToken: cancelToken,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Pas de connexion internet',
        type: DioExceptionType.connectionError,
      );
    }
    return _dio.post(path, data: data, queryParameters: queryParameters, cancelToken: cancelToken);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Pas de connexion internet',
        type: DioExceptionType.connectionError,
      );
    }
    return _dio.put(path, data: data, queryParameters: queryParameters, cancelToken: cancelToken);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Pas de connexion internet',
        type: DioExceptionType.connectionError,
      );
    }
    return _dio.patch(path, data: data, queryParameters: queryParameters, cancelToken: cancelToken);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Pas de connexion internet',
        type: DioExceptionType.connectionError,
      );
    }
    return _dio.delete(path, data: data, queryParameters: queryParameters, cancelToken: cancelToken);
  }

  Future<Response> upload(
    String path, {
    required FormData data,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Pas de connexion internet',
        type: DioExceptionType.connectionError,
      );
    }
    return _dio.post(
      path,
      data: data,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 120),
      ),
    );
  }

  Future<Response> download(
    String path,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Pas de connexion internet',
        type: DioExceptionType.connectionError,
      );
    }
    return _dio.download(
      path,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }
}
