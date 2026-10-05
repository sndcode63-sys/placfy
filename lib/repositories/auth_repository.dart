import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/auth_user_model.dart';
import '../models/legal_entity_model.dart';
import '../models/shift_info_model.dart';
import '../models/workspace_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthRepository({
    ApiClient? apiClient,
    SecureStorageService? storage,
  })  : _storage = storage ?? SecureStorageService(),
        _apiClient = apiClient ?? ApiClient(storageService: storage);

  ApiClient get apiClient => _apiClient;
  SecureStorageService get storage => _storage;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.authLogin,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;

      if (access != null && refresh != null) {
        await _storage.saveAuthTokens(
          accessToken: access,
          refreshToken: refresh,
        );
      }

      return data;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String errorMsg = 'Failed to connect to authentication server.';
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('detail')) {
          errorMsg = responseData['detail'].toString();
        } else if (responseData.containsKey('non_field_errors')) {
          final errs = responseData['non_field_errors'];
          if (errs is List && errs.isNotEmpty) {
            errorMsg = errs.first.toString();
          }
        } else if (responseData.containsKey('error')) {
          errorMsg = responseData['error'].toString();
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<AuthUserModel> getMe() async {
    try {
      final response = await _apiClient.get(AppConstants.authMe);
      return AuthUserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log('Failed to fetch user profile: $e', name: 'AuthRepository');
      rethrow;
    }
  }

  Future<List<WorkspaceModel>> getWorkspaces() async {
    try {
      final response = await _apiClient.get(AppConstants.workspaces);
      final dynamic data = response.data;

      if (data is List) {
        return data
            .map((item) => WorkspaceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('results') && data['results'] is List) {
          return (data['results'] as List)
              .map((item) =>
                  WorkspaceModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('id') || data.containsKey('slug')) {
          return [WorkspaceModel.fromJson(data)];
        }
      }
      return [];
    } catch (e) {
      developer.log('Failed to fetch workspaces: $e', name: 'AuthRepository');
      return [];
    }
  }

  Future<List<LegalEntityModel>> getMyEntities(String workspaceSlug) async {
    try {
      final response =
          await _apiClient.get(AppConstants.myEntities(workspaceSlug));
      final dynamic data = response.data;

      if (data is List) {
        return data
            .map((item) =>
                LegalEntityModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('results') && data['results'] is List) {
          return (data['results'] as List)
              .map((item) =>
                  LegalEntityModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('id') || data.containsKey('name')) {
          return [LegalEntityModel.fromJson(data)];
        }
      }
      return [];
    } catch (e) {
      developer.log('Failed to fetch legal entities: $e', name: 'AuthRepository');
      return [];
    }
  }

  Future<ShiftInfoModel> getTodayAttendance(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final Options options = Options();
      if (entityId != null) {
        options.headers = {'X-Entity-Id': entityId.toString()};
      }

      final response = await _apiClient.get(
        AppConstants.attendanceToday(workspaceSlug),
        options: options,
      );

      if (response.data is Map<String, dynamic>) {
        return ShiftInfoModel.fromJson(response.data as Map<String, dynamic>);
      }
      return ShiftInfoModel(
        date: DateTime.now().toIso8601String().substring(0, 10),
      );
    } catch (e) {
      developer.log('Failed to fetch today attendance: $e',
          name: 'AuthRepository');
      return ShiftInfoModel(
        date: DateTime.now().toIso8601String().substring(0, 10),
      );
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post(
          AppConstants.authLogout,
          data: {'refresh': refreshToken},
        );
      }
    } catch (e) {
      developer.log('Logout API call exception (clearing locally): $e',
          name: 'AuthRepository');
    } finally {
      await _storage.clearAll();
    }
  }
}
