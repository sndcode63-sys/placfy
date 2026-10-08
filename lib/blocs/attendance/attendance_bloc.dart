import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/service/verification_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../models/employee_model.dart';
import '../../models/shift_info_model.dart';
import '../../repositories/attendance_repository.dart';

// ===================== EVENTS =====================
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

/// [mode] is either 'office' or 'remote'. For office check-in the bloc itself
/// collects whatever the policy demands (location, selfie).
class StartPunchInEvent extends AttendanceEvent {
  final String mode;
  final String? remoteReason;
  final String? note;

  const StartPunchInEvent({
    this.mode = 'office',
    this.remoteReason,
    this.note,
  });

  @override
  List<Object?> get props => [mode, remoteReason, note];
}

class PauseTimerEvent extends AttendanceEvent {}

class ResumeTimerEvent extends AttendanceEvent {}

class PunchOutEvent extends AttendanceEvent {
  final String? note;
  const PunchOutEvent({this.note});
  @override
  List<Object?> get props => [note];
}

class BreakStartEvent extends AttendanceEvent {
  final int breakRuleId;
  final String? breakName;
  final int? allowedMinutes;
  final String? note;

  const BreakStartEvent({
    required this.breakRuleId,
    this.breakName,
    this.allowedMinutes,
    this.note,
  });

  @override
  List<Object?> get props => [breakRuleId, breakName, allowedMinutes, note];
}

class BreakEndEvent extends AttendanceEvent {}

class BreakTickEvent extends AttendanceEvent {
  final int seconds;
  const BreakTickEvent(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class TickerTickEvent extends AttendanceEvent {
  final int currentSeconds;
  const TickerTickEvent(this.currentSeconds);
  @override
  List<Object?> get props => [currentSeconds];
}

class ToggleGeoFenceEvent extends AttendanceEvent {}

// ===================== STATE =====================
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
  final bool isProcessing; // a check-in / out / pause call is running
  final Map<String, dynamic>? monthlySummary;
  final String? activeWorkspaceSlug;
  final int? activeEntityId;
  final ShiftInfoModel? shiftInfo; // fresh from /today/ every load
  final String? errorMessage; // user-friendly, shown as a snackbar
  final int errorSeq; // bump so the same message can show twice
  final bool onBreak;
  final String? activeBreakName;
  final int? activeBreakMinutes; // allowed length of the running break
  final DateTime? breakStartedAt;
  final int breakElapsedSeconds;

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
    this.isProcessing = false,
    this.monthlySummary,
    this.activeWorkspaceSlug,
    this.activeEntityId,
    this.shiftInfo,
    this.errorMessage,
    this.errorSeq = 0,
    this.onBreak = false,
    this.activeBreakName,
    this.activeBreakMinutes,
    this.breakStartedAt,
    this.breakElapsedSeconds = 0,
  });

  String get formattedTimer {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedBreakTimer {
    final h = breakElapsedSeconds ~/ 3600;
    final m = (breakElapsedSeconds % 3600) ~/ 60;
    final sec = breakElapsedSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
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
    bool clearPunchTimes = false,
    bool? isInsideGeoFence,
    double? distanceMeters,
    List<AttendanceRecord>? attendanceLogs,
    String? lastAuditLog,
    bool? isLoading,
    bool? isProcessing,
    Map<String, dynamic>? monthlySummary,
    String? activeWorkspaceSlug,
    int? activeEntityId,
    ShiftInfoModel? shiftInfo,
    String? errorMessage,
    int? errorSeq,
    bool? onBreak,
    String? activeBreakName,
    int? activeBreakMinutes,
    DateTime? breakStartedAt,
    int? breakElapsedSeconds,
    bool clearBreak = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      punchInTime: clearPunchTimes ? null : (punchInTime ?? this.punchInTime),
      punchOutTime: clearPunchTimes ? null : (punchOutTime ?? this.punchOutTime),
      isInsideGeoFence: isInsideGeoFence ?? this.isInsideGeoFence,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      attendanceLogs: attendanceLogs ?? this.attendanceLogs,
      lastAuditLog: lastAuditLog ?? this.lastAuditLog,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      activeWorkspaceSlug: activeWorkspaceSlug ?? this.activeWorkspaceSlug,
      activeEntityId: activeEntityId ?? this.activeEntityId,
      shiftInfo: shiftInfo ?? this.shiftInfo,
      errorMessage: errorMessage ?? this.errorMessage,
      errorSeq: errorSeq ?? this.errorSeq,
      onBreak: clearBreak ? false : (onBreak ?? this.onBreak),
      activeBreakName: clearBreak ? null : (activeBreakName ?? this.activeBreakName),
      activeBreakMinutes: clearBreak ? null : (activeBreakMinutes ?? this.activeBreakMinutes),
      breakStartedAt: clearBreak ? null : (breakStartedAt ?? this.breakStartedAt),
      breakElapsedSeconds: clearBreak ? 0 : (breakElapsedSeconds ?? this.breakElapsedSeconds),
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
    isProcessing,
    monthlySummary,
    activeWorkspaceSlug,
    activeEntityId,
    shiftInfo,
    errorMessage,
    errorSeq,
    onBreak,
    activeBreakName,
    activeBreakMinutes,
    breakStartedAt,
    breakElapsedSeconds,
  ];
}

// ===================== BLOC =====================
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _attendanceRepository;
  final SecureStorageService _storage;
  final VerificationService _verification;
  Timer? _ticker;
  DateTime _lastTick = DateTime.now();
  DateTime _lastSaved = DateTime.fromMillisecondsSinceEpoch(0);

  static const String _msgNoPolicy =
      "You don't have an active attendance policy assigned. Please contact your HR administrator.";
  static const String _msgAlreadyOut =
      'You have already checked out for today. If you need to stop temporarily, use Pause while you are checked in.';

  AttendanceBloc({
    AttendanceRepository? attendanceRepository,
    SecureStorageService? storage,
    VerificationService? verification,
  })  : _attendanceRepository = attendanceRepository ?? AttendanceRepository(),
        _storage = storage ?? SecureStorageService(),
        _verification = verification ?? VerificationService(),
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
    on<BreakTickEvent>(_onBreakTick);
    on<TickerTickEvent>(_onTick);
    on<ToggleGeoFenceEvent>(_onToggleGeoFence);

    _startTicker();
  }

  // ---------- helpers ----------
  String _todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  DateTime? _parseTime(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _fmt12(DateTime dt) => DateFormat('h:mm a').format(dt);

  void _fail(Emitter<AttendanceState> emit, String message) {
    debugPrint('🚨 [AttendanceBloc] $message');
    emit(state.copyWith(
      isProcessing: false,
      errorMessage: message,
      errorSeq: state.errorSeq + 1,
    ));
  }

  String _friendlyError(Object e) {
    if (e is VerificationException) return e.message;
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Could not reach the server. Please check your internet and try again.';
      }
      final d = e.response?.data;
      if (d is Map) {
        for (final k in ['detail', 'error', 'message']) {
          if (d[k] != null) return d[k].toString();
        }
        // field errors like {"latitude": ["This field is required."]}
        for (final entry in d.entries) {
          final v = entry.value;
          final txt = v is List && v.isNotEmpty ? v.first.toString() : v.toString();
          return '${entry.key}: $txt';
        }
      }
      if (d is String && d.isNotEmpty && d.length < 200) return d;
      return 'Something went wrong (code ${e.response?.statusCode ?? '-'}). Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  // ---------- timer ----------
  void _startTicker() {
    _ticker?.cancel();
    _lastTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (state.status == ShiftStatus.active) {
        // wall-clock based, so time still counts if Android throttled the timer
        final delta = now.difference(_lastTick).inSeconds;
        if (delta >= 1) {
          _lastTick = _lastTick.add(Duration(seconds: delta));
          add(TickerTickEvent(state.elapsedSeconds + delta));
        }
      } else {
        _lastTick = now;
        if (state.onBreak && state.breakStartedAt != null) {
          add(BreakTickEvent(now.difference(state.breakStartedAt!).inSeconds));
        }
      }
    });
  }

  void _onBreakTick(BreakTickEvent event, Emitter<AttendanceState> emit) {
    if (!state.onBreak) return;
    emit(state.copyWith(breakElapsedSeconds: event.seconds < 0 ? 0 : event.seconds));
  }

  void _onTick(TickerTickEvent event, Emitter<AttendanceState> emit) {
    emit(state.copyWith(elapsedSeconds: event.currentSeconds));
    if (DateTime.now().difference(_lastSaved).inSeconds >= 10) {
      _lastSaved = DateTime.now();
      _saveSnapshot();
    }
  }

  // ---------- session snapshot (survives app restart) ----------
  Future<void> _saveSnapshot({ShiftStatus? status, int? elapsed}) async {
    final st = status ?? state.status;
    if (st != ShiftStatus.active && st != ShiftStatus.paused) {
      await _storage.clearAttendanceSession();
      return;
    }
    await _storage.saveAttendanceSession(jsonEncode({
      'date': _todayStr(),
      'status': st.name,
      'elapsed': elapsed ?? state.elapsedSeconds,
      'savedAtMs': DateTime.now().millisecondsSinceEpoch,
      'onBreak': state.onBreak,
      'breakName': state.activeBreakName,
      'breakMinutes': state.activeBreakMinutes,
      'breakStartMs': state.breakStartedAt?.millisecondsSinceEpoch,
    }));
  }

  Future<Map<String, dynamic>?> _readSnapshot() async {
    try {
      final raw = await _storage.getAttendanceSession();
      if (raw == null || raw.isEmpty) return null;
      final m = jsonDecode(raw);
      if (m is Map<String, dynamic> && m['date'] == _todayStr()) return m;
    } catch (_) {}
    return null;
  }

  int _snapshotElapsed(Map<String, dynamic> snap, {required bool stillRunning}) {
    var elapsed = (snap['elapsed'] as num?)?.toInt() ?? 0;
    if (stillRunning && snap['status'] == ShiftStatus.active.name) {
      final savedAt = (snap['savedAtMs'] as num?)?.toInt();
      if (savedAt != null) {
        final gap = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(savedAt))
            .inSeconds;
        if (gap > 0) elapsed += gap; // time that passed while the app was closed
      }
    }
    return elapsed;
  }

  // ---------- load ----------
  Future<void> _onLoadAttendance(
      LoadAttendanceEvent event,
      Emitter<AttendanceState> emit,
      ) async {
    final slug = event.workspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = event.entityId ?? await _storage.getActiveEntityId();
    debugPrint('🔄 [AttendanceBloc] LoadAttendance slug=$slug entityId=$entityId');

    if (slug == null) {
      emit(state.copyWith(isLoading: false, lastAuditLog: 'No active workspace selected'));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      activeWorkspaceSlug: slug,
      activeEntityId: entityId,
    ));

    try {
      final todayData = await _attendanceRepository.getTodayAttendance(slug, entityId: entityId);
      debugPrint('📥 [AttendanceBloc] today keys: ${todayData.keys.toList()}');

      final serverKnown = todayData.isNotEmpty;
      final shift = serverKnown ? ShiftInfoModel.fromJson(todayData) : state.shiftInfo;
      if (shift != null) {
        debugPrint(
            '📥 [AttendanceBloc] hasPolicy=${shift.hasPolicy} modes=${shift.enabledModes} requireGeo=${shift.requireGeo} requireSelfie=${shift.requireSelfie} geoFence=${shift.geoFence}');
      }

      final snap = await _readSnapshot();
      final live = state.status == ShiftStatus.active || state.status == ShiftStatus.paused;

      ShiftStatus newStatus = state.status;
      String? punchIn = state.punchInTime;
      String? punchOut = state.punchOutTime;
      int workSec = state.elapsedSeconds;
      bool clearTimes = false;

      if (serverKnown) {
        final hasIn = todayData['has_checked_in'] as bool? ?? false;
        final hasOut = todayData['has_checked_out'] as bool? ?? false;
        final isPaused = todayData['is_timer_paused'] as bool? ?? false;

        if (!hasIn) {
          newStatus = ShiftStatus.notStarted;
          workSec = 0;
          clearTimes = true;
          await _storage.clearAttendanceSession();
        } else {
          final inDt = _parseTime(todayData['check_in_time']);
          if (inDt != null) punchIn = _fmt12(inDt);
          final serverSecs =
          ((double.tryParse(shift?.effectiveHours ?? '0') ?? 0) * 3600).round();

          if (hasOut) {
            newStatus = ShiftStatus.completed;
            final outDt = _parseTime(todayData['check_out_time']);
            if (outDt != null) punchOut = _fmt12(outDt);
            if (serverSecs > 0) {
              workSec = serverSecs;
            } else if (live) {
              workSec = state.elapsedSeconds;
            } else if (snap != null) {
              workSec = _snapshotElapsed(snap, stillRunning: false);
            } else if (inDt != null && outDt != null) {
              workSec = outDt.difference(inDt).inSeconds;
            }
            await _storage.clearAttendanceSession();
          } else {
            newStatus = isPaused ? ShiftStatus.paused : ShiftStatus.active;
            if (live) {
              workSec = state.elapsedSeconds; // app is running, memory is the truth
            } else if (snap != null) {
              workSec = _snapshotElapsed(snap, stillRunning: !isPaused); // cold start
            } else if (serverSecs > 0) {
              workSec = serverSecs;
            } else if (inDt != null) {
              workSec = DateTime.now().difference(inDt).inSeconds;
            }
            if (workSec < 0) workSec = 0;
          }
        }
      } else if (snap != null) {
        // Server unreachable: do NOT fall back to "Check In" – restore what we saved.
        newStatus = snap['status'] == ShiftStatus.paused.name
            ? ShiftStatus.paused
            : ShiftStatus.active;
        workSec = _snapshotElapsed(snap, stillRunning: newStatus == ShiftStatus.active);
        debugPrint('📴 [AttendanceBloc] server unreachable, restored saved session');
      }

      // ----- break state -----
      bool newOnBreak = state.onBreak;
      String? bName = state.activeBreakName;
      int? bMin = state.activeBreakMinutes;
      DateTime? bStart = state.breakStartedAt;
      if (newStatus == ShiftStatus.notStarted || newStatus == ShiftStatus.completed) {
        newOnBreak = false;
      } else if (serverKnown && shift != null && shift.hasBreakStateKey) {
        newOnBreak = shift.isOnBreak;
        if (newOnBreak) {
          bName = shift.activeBreakName ?? bName;
          bStart = (shift.breakStartedAt ?? bStart ?? DateTime.now()) as DateTime?;
        }
      } else if (!live && snap != null && snap['onBreak'] == true) {
        newOnBreak = true; // cold start: restore the break that was running
        bName = snap['breakName']?.toString();
        bMin = (snap['breakMinutes'] as num?)?.toInt();
        final ms = (snap['breakStartMs'] as num?)?.toInt();
        bStart = ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : DateTime.now();
      }
      if (newOnBreak && bMin == null && shift != null && bName != null) {
        bMin = shift.breakRules.where((r) => r.name == bName).firstOrNull?.durationMinutes;
      }
      // work timer must not run while on a break
      if (newOnBreak && newStatus == ShiftStatus.active) newStatus = ShiftStatus.paused;
      if (shift != null) {
        debugPrint(
            '☕ [AttendanceBloc] breakRules=${shift.breakRules.map((r) => '${r.id}:${r.name}:${r.durationMinutes}m').toList()} serverOnBreak=${shift.isOnBreak} serverHasBreakKey=${shift.hasBreakStateKey} -> onBreak=$newOnBreak');
      }

      final serverLogs = await _attendanceRepository.getAttendanceLogs(slug, entityId: entityId);
      final summary = await _attendanceRepository.getAttendanceSummary(slug, entityId: entityId);

      _lastTick = DateTime.now();
      emit(state.copyWith(
        isLoading: false,
        status: newStatus,
        punchInTime: punchIn,
        punchOutTime: punchOut,
        clearPunchTimes: clearTimes,
        elapsedSeconds: workSec,
        attendanceLogs: serverLogs.isNotEmpty ? serverLogs : state.attendanceLogs,
        monthlySummary: summary.isNotEmpty ? summary : state.monthlySummary,
        shiftInfo: shift,
        lastAuditLog: 'Attendance updated',
        onBreak: newOnBreak,
        activeBreakName: bName,
        activeBreakMinutes: bMin,
        breakStartedAt: bStart,
        breakElapsedSeconds: (newOnBreak && bStart != null)
            ? DateTime.now().difference(bStart).inSeconds.clamp(0, 86400 * 2)
            : 0,
        clearBreak: !newOnBreak,
      ));

      if (newStatus == ShiftStatus.active || newStatus == ShiftStatus.paused) {
        await _saveSnapshot(status: newStatus, elapsed: workSec);
      }
    } catch (e, st) {
      debugPrint('🚨 [AttendanceBloc] LoadAttendance crashed: $e\n$st');
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------- verification (location / selfie) ----------
  Future<({String mode, double? lat, double? lng, String? selfie})> _collectVerification(
      ShiftInfoModel? shift, {
        required bool enforceFence,
      }) async {
    final needGeo = shift?.requireGeo ?? false;
    final needSelfie = shift?.requireSelfie ?? false;
    double? lat;
    double? lng;
    String? selfie;

    if (needGeo) {
      final pos = await _verification.getCurrentLocation();
      lat = pos.latitude;
      lng = pos.longitude;

      final fence = shift!.geoFence;
      if (fence == null) {
        debugPrint('⚠️ [AttendanceBloc] policy needs geo but no office location in payload – server must enforce.');
      } else if (enforceFence) {
        final dist = _verification.distanceMeters(lat, lng, fence.latitude, fence.longitude);
        final tolerance = pos.accuracy.clamp(0, 30).toDouble();
        debugPrint('📏 [AttendanceBloc] distance=${dist.round()}m radius=${fence.radiusMeters}m tolerance=${tolerance.round()}m');
        if (dist - tolerance > fence.radiusMeters) {
          throw VerificationException(
              'You are about ${dist.round()} m from the office. Please move within ${fence.radiusMeters.round()} m of the office to continue.');
        }
      }
    }

    if (needSelfie) {
      selfie = await _verification.captureSelfie();
    }

    final mode = needGeo ? 'geo_fenced' : (needSelfie ? 'selfie' : 'standard');
    return (mode: mode, lat: lat, lng: lng, selfie: selfie);
  }

  // ---------- check in ----------
  Future<void> _onPunchIn(
      StartPunchInEvent event,
      Emitter<AttendanceState> emit,
      ) async {
    if (state.isProcessing) return;

    if (state.status == ShiftStatus.completed) {
      _fail(emit, _msgAlreadyOut);
      return;
    }
    if (state.status != ShiftStatus.notStarted) {
      _fail(emit, 'You are already checked in.');
      return;
    }

    final shift = state.shiftInfo;
    if (shift != null && !shift.hasPolicy) {
      _fail(emit, _msgNoPolicy);
      return;
    }

    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();
    if (slug == null) {
      _fail(emit, 'No workspace selected. Please sign in again.');
      return;
    }

    emit(state.copyWith(isProcessing: true));

    try {
      if (event.mode == 'remote') {
        await _attendanceRepository.checkIn(
          slug,
          entityId: entityId,
          mode: 'remote',
          remoteReason: event.remoteReason,
          note: event.note ?? 'Mobile App Check In',
        );
      } else {
        final v = await _collectVerification(shift, enforceFence: true);
        debugPrint('➡️ [AttendanceBloc] check-in mode=${v.mode} lat=${v.lat} lng=${v.lng} selfie=${v.selfie != null}');
        await _attendanceRepository.checkIn(
          slug,
          entityId: entityId,
          mode: v.mode,
          latitude: v.lat,
          longitude: v.lng,
          selfie: v.selfie,
          note: event.note ?? 'Mobile App Check In',
        );
      }

      debugPrint('✅ [AttendanceBloc] check-in saved on server');
      await _saveSnapshot(status: ShiftStatus.active, elapsed: 0);
      _lastTick = DateTime.now();
      emit(state.copyWith(isProcessing: false));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    } catch (e) {
      _fail(emit, _friendlyError(e));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    }
  }

  // ---------- pause / resume ----------
  Future<void> _onPause(PauseTimerEvent event, Emitter<AttendanceState> emit) async {
    if (state.isProcessing || state.onBreak || state.status != ShiftStatus.active) return;
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();
    if (slug == null) return;

    emit(state.copyWith(isProcessing: true));
    final frozen = state.elapsedSeconds;
    try {
      await _attendanceRepository.pauseTimer(slug, entityId: entityId, reason: 'Pause');
      await _saveSnapshot(status: ShiftStatus.paused, elapsed: frozen);
      emit(state.copyWith(isProcessing: false, status: ShiftStatus.paused, elapsedSeconds: frozen));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    } catch (e) {
      _fail(emit, _friendlyError(e));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    }
  }

  Future<void> _onResume(ResumeTimerEvent event, Emitter<AttendanceState> emit) async {
    if (state.isProcessing || state.onBreak || state.status != ShiftStatus.paused) return;
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();
    if (slug == null) return;

    emit(state.copyWith(isProcessing: true));
    try {
      await _attendanceRepository.resumeTimer(slug, entityId: entityId);
      _lastTick = DateTime.now();
      await _saveSnapshot(status: ShiftStatus.active, elapsed: state.elapsedSeconds);
      emit(state.copyWith(isProcessing: false, status: ShiftStatus.active));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    } catch (e) {
      _fail(emit, _friendlyError(e));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    }
  }

  // ---------- check out ----------
  Future<void> _onPunchOut(PunchOutEvent event, Emitter<AttendanceState> emit) async {
    if (state.isProcessing) return;
    if (state.status != ShiftStatus.active && state.status != ShiftStatus.paused) {
      _fail(emit, 'You are not checked in.');
      return;
    }
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();
    if (slug == null) return;

    emit(state.copyWith(isProcessing: true));
    try {
      final v = await _collectVerification(state.shiftInfo, enforceFence: false);
      await _attendanceRepository.checkOut(
        slug,
        entityId: entityId,
        mode: v.mode,
        latitude: v.lat,
        longitude: v.lng,
        selfie: v.selfie,
        note: event.note ?? 'Mobile App Check Out',
      );
      debugPrint('✅ [AttendanceBloc] check-out saved on server');
      await _storage.clearAttendanceSession();
      emit(state.copyWith(isProcessing: false, status: ShiftStatus.completed, clearBreak: true));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    } catch (e) {
      _fail(emit, _friendlyError(e));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    }
  }

  // ---------- breaks ----------
  Future<void> _onBreakStart(BreakStartEvent event, Emitter<AttendanceState> emit) async {
    if (state.isProcessing) return;
    if (state.status == ShiftStatus.notStarted || state.status == ShiftStatus.completed) {
      _fail(emit, 'Please check in before taking a break.');
      return;
    }
    if (state.onBreak) {
      _fail(emit, 'You are already on a break.');
      return;
    }
    if (state.status == ShiftStatus.paused) {
      _fail(emit, 'Your timer is paused. Please resume it before starting a break.');
      return;
    }
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();
    if (slug == null) return;

    emit(state.copyWith(isProcessing: true));
    try {
      await _attendanceRepository.breakStart(
        slug,
        entityId: entityId,
        breakRuleId: event.breakRuleId,
        note: event.note,
      );
      debugPrint('✅ [AttendanceBloc] break started (rule ${event.breakRuleId})');
      emit(state.copyWith(
        isProcessing: false,
        status: ShiftStatus.paused, // work timer stops during a break
        onBreak: true,
        activeBreakName: event.breakName,
        activeBreakMinutes: event.allowedMinutes,
        breakStartedAt: DateTime.now(),
        breakElapsedSeconds: 0,
      ));
      await _saveSnapshot();
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    } catch (e) {
      _fail(emit, _friendlyError(e));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    }
  }

  Future<void> _onBreakEnd(BreakEndEvent event, Emitter<AttendanceState> emit) async {
    if (state.isProcessing) return;
    if (!state.onBreak) {
      _fail(emit, 'You are not on a break.');
      return;
    }
    final slug = state.activeWorkspaceSlug ?? await _storage.getActiveWorkspace();
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();
    if (slug == null) return;

    emit(state.copyWith(isProcessing: true));
    try {
      await _attendanceRepository.breakEnd(slug, entityId: entityId);
      debugPrint('✅ [AttendanceBloc] break ended');
      _lastTick = DateTime.now();
      emit(state.copyWith(isProcessing: false, status: ShiftStatus.active, clearBreak: true));
      await _saveSnapshot();
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    } catch (e) {
      _fail(emit, _friendlyError(e));
      add(LoadAttendanceEvent(workspaceSlug: slug, entityId: entityId));
    }
  }

  void _onToggleGeoFence(ToggleGeoFenceEvent event, Emitter<AttendanceState> emit) {
    final newGeo = !state.isInsideGeoFence;
    emit(state.copyWith(
      isInsideGeoFence: newGeo,
      distanceMeters: newGeo ? 32.0 : 185.0,
    ));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}