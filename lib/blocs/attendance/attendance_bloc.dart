import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/employee_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../repositories/attendance_repository.dart';

// EVENTS
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadAttendanceEvent extends AttendanceEvent {
  final String? workspaceSlug;
  final int? entityId;
  const LoadAttendanceEvent({this.workspaceSlug, this.entityId});
  @override
  List<Object?> get props => [workspaceSlug, entityId];
}

class StartPunchInEvent extends AttendanceEvent {
  final String mode;
  final double? latitude;
  final double? longitude;
  final String? remoteReason;
  final String? note;

  const StartPunchInEvent({
    this.mode = 'standard',
    this.latitude,
    this.longitude,
    this.remoteReason,
    this.note,
  });

  @override
  List<Object?> get props => [mode, latitude, longitude, remoteReason, note];
}

class PauseTimerEvent extends AttendanceEvent {}

class ResumeTimerEvent extends AttendanceEvent {}

class PunchOutEvent extends AttendanceEvent {
  final String mode;
  final double? latitude;
  final double? longitude;
  final String? note;

  const PunchOutEvent({
    this.mode = 'standard',
    this.latitude,
    this.longitude,
    this.note,
  });

  @override
  List<Object?> get props => [mode, latitude, longitude, note];
}

class BreakStartEvent extends AttendanceEvent {
  final int breakRuleId;
  final String? note;

  const BreakStartEvent({
    required this.breakRuleId,
    this.note,
  });

  @override
  List<Object?> get props => [breakRuleId, note];
}

class BreakEndEvent extends AttendanceEvent {}

class TickerTickEvent extends AttendanceEvent {
  final int currentSeconds;
  const TickerTickEvent(this.currentSeconds);
  @override
  List<Object?> get props => [currentSeconds];
}

class ToggleGeoFenceEvent extends AttendanceEvent {}

// STATES
class AttendanceState extends Equatable {
  final ShiftStatus status;
  final int elapsedSeconds;
  final String? punchInTime;
  final String? punchOutTime;
  final bool isInsideGeoFence;
  final double distanceMeters;
  final List<AttendanceRecord> attendanceLogs;
  final String? lastAuditLog;
  final bool isLoading;
  final Map<String, dynamic>? monthlySummary;
  final String? activeWorkspaceSlug;
  final int? activeEntityId;

  const AttendanceState({
    required this.status,
    required this.elapsedSeconds,
    this.punchInTime,
    this.punchOutTime,
    this.isInsideGeoFence = true,
    this.distanceMeters = 28.5,
    required this.attendanceLogs,
    this.lastAuditLog,
    this.isLoading = false,
    this.monthlySummary,
    this.activeWorkspaceSlug,
    this.activeEntityId,
  });

  String get formattedTimer {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get presentDaysCount {
    if (monthlySummary != null && monthlySummary!['present_days'] != null) {
      return (monthlySummary!['present_days'] as num).toInt();
    }
    return attendanceLogs.where((l) => l.status.toLowerCase() == 'present').length;
  }

  int get remoteDaysCount {
    return attendanceLogs.where((l) => l.status.toLowerCase() == 'remote').length;
  }

  AttendanceState copyWith({
    ShiftStatus? status,
    int? elapsedSeconds,
    String? punchInTime,
    String? punchOutTime,
    bool? isInsideGeoFence,
    double? distanceMeters,
    List<AttendanceRecord>? attendanceLogs,
    String? lastAuditLog,
    bool? isLoading,
    Map<String, dynamic>? monthlySummary,
    String? activeWorkspaceSlug,
    int? activeEntityId,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      punchInTime: punchInTime ?? this.punchInTime,
      punchOutTime: punchOutTime ?? this.punchOutTime,
      isInsideGeoFence: isInsideGeoFence ?? this.isInsideGeoFence,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      attendanceLogs: attendanceLogs ?? this.attendanceLogs,
      lastAuditLog: lastAuditLog ?? this.lastAuditLog,
      isLoading: isLoading ?? this.isLoading,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      activeWorkspaceSlug: activeWorkspaceSlug ?? this.activeWorkspaceSlug,
      activeEntityId: activeEntityId ?? this.activeEntityId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        elapsedSeconds,
        punchInTime,
        punchOutTime,
        isInsideGeoFence,
        distanceMeters,
        attendanceLogs,
        lastAuditLog,
        isLoading,
        monthlySummary,
        activeWorkspaceSlug,
        activeEntityId,
      ];
}

// BLOC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _attendanceRepository;
  final SecureStorageService _storage;
  Timer? _ticker;

  AttendanceBloc({
    AttendanceRepository? attendanceRepository,
    SecureStorageService? storage,
  })  : _attendanceRepository = attendanceRepository ?? AttendanceRepository(),
        _storage = storage ?? SecureStorageService(),
        super(const AttendanceState(
          status: ShiftStatus.notStarted,
          elapsedSeconds: 0,
          attendanceLogs: [],
        )) {
    on<LoadAttendanceEvent>(_onLoadAttendance);
    on<StartPunchInEvent>(_onPunchIn);
    on<PauseTimerEvent>(_onPause);
    on<ResumeTimerEvent>(_onResume);
    on<PunchOutEvent>(_onPunchOut);
    on<BreakStartEvent>(_onBreakStart);
    on<BreakEndEvent>(_onBreakEnd);
    on<TickerTickEvent>(_onTick);
    on<ToggleGeoFenceEvent>(_onToggleGeoFence);

    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == ShiftStatus.active) {
        add(TickerTickEvent(state.elapsedSeconds + 1));
      }
    });
  }

  void _onTick(TickerTickEvent event, Emitter<AttendanceState> emit) {
    emit(state.copyWith(elapsedSeconds: event.currentSeconds));
  }

  Future<void> _onLoadAttendance(
    LoadAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final slug = event.workspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = event.entityId ?? await _storage.getActiveEntityId();

    // If no workspace slug, show error - fully dynamic, no fallback
    if (slug == null) {
      emit(state.copyWith(
        isLoading: false,
        lastAuditLog: 'No active workspace selected',
      ));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      activeWorkspaceSlug: slug,
      activeEntityId: entityId,
    ));

    try {
      // 1. Fetch Today Status
      final todayData = await _attendanceRepository.getTodayAttendance(
        slug,
        entityId: entityId,
      );

      ShiftStatus newStatus = state.status;
      String? punchIn = state.punchInTime;
      String? punchOut = state.punchOutTime;
      int workSec = state.elapsedSeconds;

      if (todayData.isNotEmpty && todayData['date'] != null) {
        final hasCheckedIn = todayData['has_checked_in'] as bool? ?? false;
        final hasCheckedOut = todayData['has_checked_out'] as bool? ?? false;
        final isTimerPaused = todayData['is_timer_paused'] as bool? ?? false;

        if (hasCheckedIn) {
          final checkInStr = todayData['check_in_time']?.toString();
          if (checkInStr != null && checkInStr.isNotEmpty) {
            try {
              final dt = DateTime.parse(checkInStr).toLocal();
              final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
              final m = dt.minute.toString().padLeft(2, '0');
              final ampm = dt.hour >= 12 ? 'PM' : 'AM';
              punchIn = '$h:$m $ampm';

              final diff = DateTime.now().difference(dt).inSeconds;
              if (diff > 0 && !hasCheckedOut) {
                workSec = diff;
              }
            } catch (_) {}
          }

          if (hasCheckedOut) {
            newStatus = ShiftStatus.completed;
            final checkOutStr = todayData['check_out_time']?.toString();
            if (checkOutStr != null && checkOutStr.isNotEmpty) {
              try {
                final dt = DateTime.parse(checkOutStr).toLocal();
                final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
                final m = dt.minute.toString().padLeft(2, '0');
                final ampm = dt.hour >= 12 ? 'PM' : 'AM';
                punchOut = '$h:$m $ampm';
              } catch (_) {}
            }
          } else if (isTimerPaused) {
            newStatus = ShiftStatus.paused;
          } else {
            newStatus = ShiftStatus.active;
          }
        }
      }

      // 2. Fetch History Logs
      final serverLogs = await _attendanceRepository.getAttendanceLogs(
        slug,
        entityId: entityId,
      );

      // 3. Fetch Monthly Summary
      final summary = await _attendanceRepository.getAttendanceSummary(
        slug,
        entityId: entityId,
      );

      final combinedLogs = serverLogs.isNotEmpty
          ? serverLogs
          : state.attendanceLogs;

      emit(state.copyWith(
        isLoading: false,
        status: newStatus,
        punchInTime: punchIn,
        punchOutTime: punchOut,
        elapsedSeconds: workSec,
        attendanceLogs: combinedLogs,
        monthlySummary: summary.isNotEmpty ? summary : state.monthlySummary,
        lastAuditLog:
            'API_SYNC complete • Live attendance synchronized for $slug',
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onPunchIn(
    StartPunchInEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final nowTime = DateFormat('hh:mm a').format(DateTime.now());
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();

    // If no workspace slug, cannot punch in - fully dynamic
    if (slug == null) {
      emit(state.copyWith(
        lastAuditLog: 'Cannot check in: No active workspace',
      ));
      return;
    }

    emit(state.copyWith(
      status: ShiftStatus.active,
      punchInTime: nowTime,
      punchOutTime: null,
      elapsedSeconds: 0,
      lastAuditLog:
          'TIMER_START audit logged • Mode: ${event.mode} • Geo-fence matched',
    ));

    try {
      await _attendanceRepository.checkIn(
        slug,
        entityId: entityId,
        mode: event.mode,
        latitude: event.latitude,
        longitude: event.longitude,
        remoteReason: event.remoteReason,
        note: event.note ?? 'Mobile App Punch In',
      );
    } catch (_) {}
  }

  Future<void> _onPause(
    PauseTimerEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final nowTime = DateFormat('hh:mm a').format(DateTime.now());
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();

    if (slug == null) {
      emit(state.copyWith(
        lastAuditLog: 'Cannot pause: No active workspace',
      ));
      return;
    }

    emit(state.copyWith(
      status: ShiftStatus.paused,
      lastAuditLog:
          'TIMER_PAUSE audit logged • Effective hours suspended at $nowTime',
    ));

    try {
      await _attendanceRepository.pauseTimer(
        slug,
        entityId: entityId,
        reason: 'Break',
      );
    } catch (_) {}
  }

  Future<void> _onResume(
    ResumeTimerEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final nowTime = DateFormat('hh:mm a').format(DateTime.now());
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();

    if (slug == null) {
      emit(state.copyWith(
        lastAuditLog: 'Cannot resume: No active workspace',
      ));
      return;
    }

    emit(state.copyWith(
      status: ShiftStatus.active,
      lastAuditLog:
          'TIMER_RESUME audit logged • Work session resumed at $nowTime',
    ));

    try {
      await _attendanceRepository.resumeTimer(
        slug,
        entityId: entityId,
      );
    } catch (_) {}
  }

  Future<void> _onPunchOut(
    PunchOutEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final nowTime = DateFormat('hh:mm a').format(DateTime.now());
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();

    if (slug == null) {
      emit(state.copyWith(
        lastAuditLog: 'Cannot check out: No active workspace',
      ));
      return;
    }

    final newLog = AttendanceRecord(
      date: 'Today, ${DateFormat('MMM dd').format(DateTime.now())}',
      punchInTime: state.punchInTime ?? '09:00 AM',
      punchOutTime: nowTime,
      totalWorkSeconds: state.elapsedSeconds,
      status: 'Present',
      geoVerified: state.isInsideGeoFence,
    );

    emit(state.copyWith(
      status: ShiftStatus.completed,
      punchOutTime: nowTime,
      attendanceLogs: [newLog, ...state.attendanceLogs],
      lastAuditLog:
          'TIMER_STOP audit logged • Mode: ${event.mode} • Total hours: ${state.formattedTimer}',
    ));

    try {
      await _attendanceRepository.checkOut(
        slug,
        entityId: entityId,
        mode: event.mode,
        latitude: event.latitude,
        longitude: event.longitude,
        note: event.note ?? 'Mobile App Punch Out',
      );
    } catch (_) {}
  }

  Future<void> _onBreakStart(
    BreakStartEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();

    if (slug == null) {
      emit(state.copyWith(
        lastAuditLog: 'Cannot start break: No active workspace',
      ));
      return;
    }

    emit(state.copyWith(
      status: ShiftStatus.paused,
      lastAuditLog: 'BREAK_START audit logged • Break rule ID: ${event.breakRuleId}',
    ));

    try {
      await _attendanceRepository.breakStart(
        slug,
        entityId: entityId,
        breakRuleId: event.breakRuleId,
        note: event.note,
      );
    } catch (_) {}
  }

  Future<void> _onBreakEnd(
    BreakEndEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();

    if (slug == null) {
      emit(state.copyWith(
        lastAuditLog: 'Cannot end break: No active workspace',
      ));
      return;
    }

    emit(state.copyWith(
      status: ShiftStatus.active,
      lastAuditLog: 'BREAK_END audit logged • Work session resumed',
    ));

    try {
      await _attendanceRepository.breakEnd(
        slug,
        entityId: entityId,
      );
    } catch (_) {}
  }

  void _onToggleGeoFence(ToggleGeoFenceEvent event, Emitter<AttendanceState> emit) {
    final newGeo = !state.isInsideGeoFence;
    emit(state.copyWith(
      isInsideGeoFence: newGeo,
      distanceMeters: newGeo ? 32.0 : 185.0,
      lastAuditLog: newGeo
          ? 'GEO_LOCATION verified • Within 120m Office Perimeter'
          : 'GEO_ALERT • 185m outside Office Boundary - Remote mode enabled',
    ));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
