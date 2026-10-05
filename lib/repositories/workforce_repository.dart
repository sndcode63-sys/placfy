import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/workspace_member_model.dart';

class WorkforceRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  WorkforceRepository({
    ApiClient? apiClient,
    SecureStorageService? storage,
  })  : _storage = storage ?? SecureStorageService(),
        _apiClient = apiClient ?? ApiClient(storageService: storage);

  ApiClient get apiClient => _apiClient;
  SecureStorageService get storage => _storage;

  Options _buildOptions(int? entityId) {
    final Options options = Options();
    if (entityId != null) {
      options.headers = {'X-Entity-Id': entityId.toString()};
    }
    return options;
  }

  Future<List<WorkspaceMemberModel>> getWorkspaceMembers(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.workspaceMembers(workspaceSlug),
        options: _buildOptions(entityId),
      );

      final dynamic data = response.data;
      if (data is List) {
        return data
            .map((item) =>
                WorkspaceMemberModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> &&
          data.containsKey('results') &&
          data['results'] is List) {
        return (data['results'] as List)
            .map((item) =>
                WorkspaceMemberModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      developer.log('Failed to fetch workspace members: $e',
          name: 'WorkforceRepository');
    }
    return [];
  }
}
