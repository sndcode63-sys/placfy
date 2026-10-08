import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/employee_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AttendanceRepository({
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

  /// Fetch today's real attendance status from server
  Future<Map<String, dynamic>> getTodayAttendance(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.attendanceToday(workspaceSlug),
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to fetch today attendance: $e',
          name: 'AttendanceRepository');
      return {};
    }
  }

  /// Fetch attendance history logs from server
  Future<List<AttendanceRecord>> getAttendanceLogs(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.attendanceLogs(workspaceSlug),
        options: _buildOptions(entityId),
      );

      final dynamic data = response.data;
      if (data is List) {
        return data
            .map((item) =>
                AttendanceRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> &&
          data.containsKey('results') &&
          data['results'] is List) {
        return (data['results'] as List)
            .map((item) =>
                AttendanceRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      developer.log('Failed to fetch attendance logs: $e',
          name: 'AttendanceRepository');
      return [];
    }
  }

  /// Fetch monthly attendance metrics summary from server
  Future<Map<String, dynamic>> getAttendanceSummary(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.attendanceSummary(workspaceSlug),
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to fetch attendance summary: $e',
          name: 'AttendanceRepository');
      return {};
    }
  }

  /// Punch in / Check in to work session
  Future<Map<String, dynamic>> checkIn(
    String workspaceSlug, {
    int? entityId,
    required String mode,
    double? latitude,
    double? longitude,
    String? selfie,
    String? remoteReason,
    String? source,
    String? deviceInfo,
    String? note,
  }) async {
    try {
      final formData = FormData.fromMap({
        'mode': mode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (selfie != null) 'selfie': selfie,
        if (remoteReason != null) 'remote_reason': remoteReason,
        if (source != null) 'source': source,
        if (deviceInfo != null) 'device_info': deviceInfo,
        if (note != null) 'note': note,
      });

      final response = await _apiClient.post(
        AppConstants.attendanceCheckIn(workspaceSlug),
        data: formData,
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to punch in: $e', name: 'AttendanceRepository');
      rethrow;
    }
  }

  /// Punch out / Check out from work session
  Future<Map<String, dynamic>> checkOut(
    String workspaceSlug, {
    int? entityId,
    required String mode,
    double? latitude,
    double? longitude,
    String? selfie,
    String? source,
    String? note,
  }) async {
    try {
      final formData = FormData.fromMap({
        'mode': mode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (selfie != null) 'selfie': selfie,
        if (source != null) 'source': source,
        if (note != null) 'note': note,
      });

      final response = await _apiClient.post(
        AppConstants.attendanceCheckOut(workspaceSlug),
        data: formData,
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to punch out: $e', name: 'AttendanceRepository');
      rethrow;
    }
  }

  /// Pause work session timer
  Future<Map<String, dynamic>> pauseTimer(
    String workspaceSlug, {
    int? entityId,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.attendancePauseTimer(workspaceSlug),
        data: {
          if (reason != null) 'reason': reason,
        },
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to pause timer: $e', name: 'AttendanceRepository');
      rethrow;
    }
  }

  /// Resume work session timer
  Future<Map<String, dynamic>> resumeTimer(
    String workspaceSlug, {
    int? entityId,
    String? note,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.attendanceResumeTimer(workspaceSlug),
        data: {
          if (note != null) 'note': note,
        },
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to resume timer: $e', name: 'AttendanceRepository');
      rethrow;
    }
  }

  /// Start a break
  Future<Map<String, dynamic>> breakStart(
    String workspaceSlug, {
    int? entityId,
    required int breakRuleId,
    String? note,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.attendanceBreakStart(workspaceSlug),
        data: {
          'break_rule_id': breakRuleId,
          if (note != null) 'note': note,
        },
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to start break: $e', name: 'AttendanceRepository');
      rethrow;
    }
  }

  /// End a break
  Future<Map<String, dynamic>> breakEnd(
    String workspaceSlug, {
    int? entityId,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.attendanceBreakEnd(workspaceSlug),
        data: {},
        options: _buildOptions(entityId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      developer.log('Failed to end break: $e', name: 'AttendanceRepository');
      rethrow;
    }
  }
}
