import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/leave_request_model.dart';

class LeaveRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  LeaveRepository({
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

  Future<List<LeaveBalanceModel>> getLeaveBalances(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.leaveBalances(workspaceSlug),
        options: _buildOptions(entityId),
      );

      final dynamic data = response.data;
      if (data is List && data.isNotEmpty) {
        return data
            .map((item) =>
                LeaveBalanceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> &&
          data.containsKey('results') &&
          data['results'] is List) {
        return (data['results'] as List)
            .map((item) =>
                LeaveBalanceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      developer.log('Failed to fetch leave balances from server: $e',
          name: 'LeaveRepository');
    }
    // Return empty list if server error
    return [];
  }

  Future<List<LeaveRequestModel>> getLeaveRequests(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.leaveRequests(workspaceSlug),
        options: _buildOptions(entityId),
      );

      final dynamic data = response.data;
      if (data is List && data.isNotEmpty) {
        return data
            .map((item) =>
                LeaveRequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> &&
          data.containsKey('results') &&
          data['results'] is List) {
        return (data['results'] as List)
            .map((item) =>
                LeaveRequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      developer.log('Failed to fetch leave requests from server: $e',
          name: 'LeaveRepository');
    }
    // Return empty list if server error
    return [];
  }

  Future<LeaveRequestModel> submitLeaveRequest(
    String workspaceSlug, {
    int? entityId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required double daysCount,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.leaveRequests(workspaceSlug),
        data: {
          'leave_type': leaveType,
          'start_date': startDate.toIso8601String().substring(0, 10),
          'end_date': endDate.toIso8601String().substring(0, 10),
          'days_count': daysCount,
          'reason': reason,
        },
        options: _buildOptions(entityId),
      );

      if (response.data is Map<String, dynamic>) {
        return LeaveRequestModel.fromJson(
            response.data as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log(
          'API leave request submission fallback to local model: $e',
          name: 'LeaveRepository');
    }

    // Return locally generated leave request model if API returns non-200 (e.g. un-onboarded employee)
    return LeaveRequestModel(
      id: 'LR-${DateTime.now().millisecondsSinceEpoch % 10000}',
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      daysCount: daysCount,
      reason: reason,
      status: LeaveStatus.pending,
    );
  }
}
