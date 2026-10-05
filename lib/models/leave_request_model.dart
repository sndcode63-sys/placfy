import 'package:equatable/equatable.dart';

enum LeaveStatus { pending, approved, rejected }

class LeaveRequestModel extends Equatable {
  final String id;
  final String leaveType; // 'Earned Leave', 'Casual Leave', 'Sick Leave', 'Comp Off'
  final DateTime startDate;
  final DateTime endDate;
  final double daysCount;
  final String reason;
  final LeaveStatus status;
  final String? approvedBy;

  const LeaveRequestModel({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.reason,
    required this.status,
    this.approvedBy,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    LeaveStatus parsedStatus = LeaveStatus.pending;
    final rawStatus = (json['status']?.toString() ?? '').toLowerCase();
    if (rawStatus.contains('approve')) {
      parsedStatus = LeaveStatus.approved;
    } else if (rawStatus.contains('reject')) {
      parsedStatus = LeaveStatus.rejected;
    }

    DateTime start = DateTime.now();
    if (json['start_date'] != null) {
      try {
        start = DateTime.parse(json['start_date'].toString());
      } catch (_) {}
    }

    DateTime end = start;
    if (json['end_date'] != null) {
      try {
        end = DateTime.parse(json['end_date'].toString());
      } catch (_) {}
    }

    return LeaveRequestModel(
      id: json['id']?.toString() ?? json['public_id']?.toString() ?? 'LR-REQ',
      leaveType: json['leave_type_name']?.toString() ??
          json['leave_type']?.toString() ??
          'Casual Leave',
      startDate: start,
      endDate: end,
      daysCount: double.tryParse(json['days_count']?.toString() ??
              json['days']?.toString() ??
              '1') ??
          1.0,
      reason: json['reason']?.toString() ?? json['note']?.toString() ?? 'General Leave',
      status: parsedStatus,
      approvedBy: json['approved_by']?.toString() ?? json['approver_name']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        leaveType,
        startDate,
        endDate,
        daysCount,
        reason,
        status,
        approvedBy,
      ];
}

class LeaveBalanceModel extends Equatable {
  final String leaveType;
  final double totalAllocated;
  final double used;
  final double remaining;

  const LeaveBalanceModel({
    required this.leaveType,
    required this.totalAllocated,
    required this.used,
    required this.remaining,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    final allocated = double.tryParse(json['allocated']?.toString() ??
            json['total_allocated']?.toString() ??
            '12') ??
        12.0;
    final used = double.tryParse(json['used']?.toString() ??
            json['used_days']?.toString() ??
            '0') ??
        0.0;
    final remaining = double.tryParse(json['remaining']?.toString() ??
            json['balance']?.toString() ??
            (allocated - used).toString()) ??
        (allocated - used);

    return LeaveBalanceModel(
      leaveType: json['leave_type_name']?.toString() ??
          json['name']?.toString() ??
          'Paid Leave',
      totalAllocated: allocated,
      used: used,
      remaining: remaining,
    );
  }

  @override
  List<Object?> get props => [leaveType, totalAllocated, used, remaining];
}
