import 'package:equatable/equatable.dart';

class ShiftInfoModel extends Equatable {
  final String date;
  final String shiftName;
  final String shiftStart;
  final String shiftEnd;
  final String status;
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final String? checkInTime;
  final String? checkOutTime;
  final String effectiveHours;
  final String policyName;
  final bool hasPolicy;
  final bool isHoliday;
  final String? holidayName;
  final bool isWeekOff;
  final List<String> enabledModes;
  final bool requireSelfie;
  final bool requireGeo;
  final bool allowRemoteCheckin;

  const ShiftInfoModel({
    required this.date,
    this.shiftName = 'General Shift',
    this.shiftStart = '09:00:00',
    this.shiftEnd = '18:00:00',
    this.status = 'not_marked',
    this.hasCheckedIn = false,
    this.hasCheckedOut = false,
    this.checkInTime,
    this.checkOutTime,
    this.effectiveHours = '0.00',
    this.policyName = 'Standard Attendance Policy',
    this.hasPolicy = true,
    this.isHoliday = false,
    this.holidayName,
    this.isWeekOff = false,
    this.enabledModes = const ['standard'],
    this.requireSelfie = false,
    this.requireGeo = false,
    this.allowRemoteCheckin = true,
  });

  String get formattedHours {
    final start = shiftStart.length >= 5 ? shiftStart.substring(0, 5) : shiftStart;
    final end = shiftEnd.length >= 5 ? shiftEnd.substring(0, 5) : shiftEnd;
    return '$start - $end';
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'on_time':
        return 'On Time';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      case 'half_day':
        return 'Half Day';
      case 'not_marked':
      default:
        return 'Not Marked Yet';
    }
  }

  factory ShiftInfoModel.fromJson(Map<String, dynamic> json) {
    final enabledModesList = json['enabled_modes'] as List<dynamic>?;
    final modes = enabledModesList?.map((e) => e.toString()).toList() ?? ['standard'];

    return ShiftInfoModel(
      date: json['date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      shiftName: json['shift_name'] as String? ?? 'General Shift',
      shiftStart: json['shift_start'] as String? ?? '09:00:00',
      shiftEnd: json['shift_end'] as String? ?? '18:00:00',
      status: json['status'] as String? ?? 'not_marked',
      hasCheckedIn: json['has_checked_in'] as bool? ?? false,
      hasCheckedOut: json['has_checked_out'] as bool? ?? false,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      effectiveHours: json['effective_hours']?.toString() ?? '0.00',
      policyName: json['policy_name'] as String? ?? 'Standard Attendance Policy',
      hasPolicy: json['has_policy'] as bool? ?? true,
      isHoliday: json['is_holiday'] as bool? ?? false,
      holidayName: json['holiday_name'] as String?,
      isWeekOff: json['is_week_off'] as bool? ?? false,
      enabledModes: modes,
      requireSelfie: json['require_selfie'] as bool? ?? false,
      requireGeo: json['require_geo'] as bool? ?? false,
      allowRemoteCheckin: json['allow_remote_checkin'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        date,
        shiftName,
        shiftStart,
        shiftEnd,
        status,
        hasCheckedIn,
        hasCheckedOut,
        checkInTime,
        checkOutTime,
        effectiveHours,
        policyName,
        hasPolicy,
        isHoliday,
        holidayName,
        isWeekOff,
        enabledModes,
        requireSelfie,
        requireGeo,
        allowRemoteCheckin,
      ];
}
