import 'package:equatable/equatable.dart';

enum ShiftStatus { active, paused, completed, notStarted }

class EmployeeModel extends Equatable {
  final String id;
  final String fullName;
  final String role;
  final String department;
  final String email;
  final String avatarUrl;
  final String workspaceSlug;
  final bool isInsideOfficeGeoFence;
  final double officeDistanceMeters;

  const EmployeeModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.department,
    required this.email,
    required this.avatarUrl,
    required this.workspaceSlug,
    this.isInsideOfficeGeoFence = true,
    this.officeDistanceMeters = 34.0,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        role,
        department,
        email,
        avatarUrl,
        workspaceSlug,
        isInsideOfficeGeoFence,
        officeDistanceMeters,
      ];
}

class AttendanceRecord extends Equatable {
  final String date;
  final String punchInTime;
  final String? punchOutTime;
  final int totalWorkSeconds;
  final String status; // 'Present', 'Remote', 'Half Day', 'On Leave'
  final bool geoVerified;

  const AttendanceRecord({
    required this.date,
    required this.punchInTime,
    this.punchOutTime,
    required this.totalWorkSeconds,
    required this.status,
    this.geoVerified = true,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final rawIn = json['first_check_in']?.toString();
    String formattedIn = '--:--';
    if (rawIn != null && rawIn.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawIn).toLocal();
        final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
        final min = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        formattedIn = '$hour:$min $ampm';
      } catch (_) {
        formattedIn = rawIn;
      }
    }

    final rawOut = json['last_check_out']?.toString();
    String? formattedOut;
    if (rawOut != null && rawOut.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawOut).toLocal();
        final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
        final min = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        formattedOut = '$hour:$min $ampm';
      } catch (_) {
        formattedOut = rawOut;
      }
    }

    final hours = double.tryParse(json['effective_hours']?.toString() ?? '0') ?? 0.0;
    final totalSec = (hours * 3600).round();

    return AttendanceRecord(
      date: json['date']?.toString() ?? 'Recent',
      punchInTime: formattedIn,
      punchOutTime: formattedOut,
      totalWorkSeconds: totalSec > 0 ? totalSec : 0,
      status: json['status_display']?.toString() ??
          (json['status']?.toString().toUpperCase() ?? 'Present'),
      geoVerified: !(json['is_remote'] as bool? ?? false),
    );
  }

  String get formattedDuration {
    final hours = totalWorkSeconds ~/ 3600;
    final minutes = (totalWorkSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  @override
  List<Object?> get props => [
        date,
        punchInTime,
        punchOutTime,
        totalWorkSeconds,
        status,
        geoVerified,
      ];
}
