import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  static const String liveBaseUrl = AppConstants.apiBaseUrl;
  static const String localBaseUrl = AppConstants.apiLocalBaseUrl;

  final Dio _dio;
  final SecureStorageService _storageService;

  ApiClient({
    String? baseUrl,
    SecureStorageService? storageService,
  })  : _storageService = storageService ?? SecureStorageService(),
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? liveBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              AppConstants.ngrokSkipHeader: AppConstants.ngrokSkipHeaderValue,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _setupInterceptors();
  }

  Dio get dio => _dio;
  SecureStorageService get storage => _storageService;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always ensure ngrok header is present
          options.headers[AppConstants.ngrokSkipHeader] =
              AppConstants.ngrokSkipHeaderValue;

          // Inject access token if available
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Inject active entity ID if available
          final entityId = await _storageService.getActiveEntityId();
          if (entityId != null) {
            options.headers['X-Entity-Id'] = entityId.toString();
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Check for 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final requestPath = error.requestOptions.path;
            final isAuthEndpoint = requestPath.contains(AppConstants.authLogin) ||
                requestPath.contains(AppConstants.authRefresh) ||
                requestPath.contains(AppConstants.authLogout);

            if (!isAuthEndpoint) {
              final refreshToken = await _storageService.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                try {
                  developer.log('Token expired. Attempting silent refresh...',
                      name: 'ApiClient');

                  // Create a clean Dio instance for refresh call to avoid infinite loops
                  final refreshDio = Dio(
                    BaseOptions(
                      baseUrl: _dio.options.baseUrl,
                      headers: {
                        AppConstants.ngrokSkipHeader:
                            AppConstants.ngrokSkipHeaderValue,
                        'Content-Type': 'application/json',
                      },
                    ),
                  );

                  final refreshResponse = await refreshDio.post(
                    AppConstants.authRefresh,
                    data: {'refresh': refreshToken},
                  );

                  if (refreshResponse.statusCode == 200) {
                    final data = refreshResponse.data;
                    final newAccess = data['access'] as String?;
                    final newRefresh = data['refresh'] as String?;

                    if (newAccess != null) {
                      await _storageService.updateAccessToken(newAccess);
                      if (newRefresh != null) {
                        await _storageService.saveAuthTokens(
                          accessToken: newAccess,
                          refreshToken: newRefresh,
                        );
                      }

                      // Retry the original request with new token
                      final opts = error.requestOptions;
                      opts.headers['Authorization'] = 'Bearer $newAccess';

                      final retryResponse = await _dio.fetch(opts);
                      return handler.resolve(retryResponse);
                    }
                  }
                } catch (e) {
                  developer.log('Silent refresh failed: $e', name: 'ApiClient');
                  await _storageService.clearAll();
                }
              } else {
                await _storageService.clearAll();
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
