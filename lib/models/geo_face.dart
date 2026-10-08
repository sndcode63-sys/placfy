import 'package:equatable/equatable.dart';

/// Office location + allowed radius configured in the attendance policy.
class GeoFenceInfo extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const GeoFenceInfo({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusMeters];
}

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
  final GeoFenceInfo? geoFence;

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
    this.policyName = '',
    this.hasPolicy = true,
    this.isHoliday = false,
    this.holidayName,
    this.isWeekOff = false,
    this.enabledModes = const ['standard'],
    this.requireSelfie = false,
    this.requireGeo = false,
    this.allowRemoteCheckin = true,
    this.geoFence,
  });

  String get formattedHours {
    final start = shiftStart.length >= 5 ? shiftStart.substring(0, 5) : shiftStart;
    final end = shiftEnd.length >= 5 ? shiftEnd.substring(0, 5) : shiftEnd;
    return '$start - $end';
  }

  /// True if the policy allows checking in from the office (not only remote).
  bool get allowOfficeCheckin =>
      enabledModes.isEmpty || enabledModes.any((m) => m != 'remote') || requireGeo || requireSelfie;

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

  // ---------- tolerant JSON helpers (backend key names may vary) ----------
  static dynamic _first(List<Map<String, dynamic>?> maps, List<String> keys) {
    for (final m in maps) {
      if (m == null) continue;
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) return m[k];
      }
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;

  static double? _num(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());

  static GeoFenceInfo? _parseGeoFence(List<Map<String, dynamic>?> sources) {
    final nested = _asMap(_first(sources,
        ['geo_fence', 'geofence', 'geo_fence_config', 'office_location', 'office']));
    final all = <Map<String, dynamic>?>[nested, ...sources];
    final lat = _num(_first(all, ['latitude', 'lat', 'office_latitude', 'geo_latitude']));
    final lng = _num(_first(all, ['longitude', 'lng', 'lon', 'office_longitude', 'geo_longitude']));
    final radius = _num(_first(all, [
      'radius_meters',
      'radius_m',
      'radius',
      'geo_radius',
      'geofence_radius',
      'geo_fence_radius',
      'allowed_radius',
    ]));
    if (lat == null || lng == null || radius == null || radius <= 0) return null;
    return GeoFenceInfo(latitude: lat, longitude: lng, radiusMeters: radius);
  }

  factory ShiftInfoModel.fromJson(Map<String, dynamic> json) {
    final policy = _asMap(json['policy']) ?? _asMap(json['attendance_policy']);
    final sources = <Map<String, dynamic>?>[json, policy];

    final rawModes = _first(sources, ['enabled_modes', 'allowed_modes', 'modes']);
    final modes = rawModes is List
        ? rawModes.map((e) => e.toString()).toList()
        : <String>['standard'];

    final policyName =
    (_first(sources, ['policy_name', 'name']) ?? '').toString();

    // Policy present?  Explicit flag wins; otherwise infer from payload.
    bool hasPolicy;
    final flag = json['has_policy'];
    if (flag is bool) {
      hasPolicy = flag;
    } else if (policy != null ||
        json.containsKey('policy_name') ||
        json.containsKey('policy_id') ||
        json.containsKey('policy')) {
      hasPolicy = policy != null ||
          policyName.isNotEmpty ||
          json['policy_id'] != null;
    } else {
      hasPolicy = true; // payload says nothing about policy -> don't block
    }

    final selfieFlag = _first(sources, ['require_selfie', 'selfie_required']);
    final geoFlag = _first(sources, ['require_geo', 'geo_required', 'require_geofence']);
    final requireSelfie = selfieFlag == true || modes.contains('selfie');
    final requireGeo = geoFlag == true || modes.contains('geo_fenced');

    final remoteFlag = _first(sources, ['allow_remote_checkin', 'allow_remote']);

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
      policyName: policyName,
      hasPolicy: hasPolicy,
      isHoliday: json['is_holiday'] as bool? ?? false,
      holidayName: json['holiday_name'] as String?,
      isWeekOff: json['is_week_off'] as bool? ?? false,
      enabledModes: modes,
      requireSelfie: requireSelfie,
      requireGeo: requireGeo,
      allowRemoteCheckin: remoteFlag is bool ? remoteFlag : modes.contains('remote') || modes.length <= 1,
      geoFence: _parseGeoFence(sources),
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
    geoFence,
  ];
}
