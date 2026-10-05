import 'package:equatable/equatable.dart';

class WorkspaceMemberModel extends Equatable {
  final int id;
  final int userId;
  final String username;
  final String userEmail;
  final String userFullName;
  final String role;
  final bool isActive;
  final String joinedAt;

  const WorkspaceMemberModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userEmail,
    required this.userFullName,
    required this.role,
    required this.isActive,
    required this.joinedAt,
  });

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      userFullName: json['user_full_name']?.toString() ??
          json['username']?.toString() ??
          'Team Member',
      role: json['role']?.toString() ?? 'member',
      isActive: json['is_active'] as bool? ?? true,
      joinedAt: json['joined_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        userEmail,
        userFullName,
        role,
        isActive,
        joinedAt,
      ];
}
