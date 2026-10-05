import 'package:equatable/equatable.dart';

class AuthUserModel extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final List<String> roles;
  final bool hasWorkspaceAccess;
  final String defaultRedirect;

  const AuthUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.roles,
    this.hasWorkspaceAccess = true,
    this.defaultRedirect = 'workspace',
  });

  String get primaryRole => roles.isNotEmpty ? roles.first : 'employee';

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (fullName.isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U';
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final accessContext = json['access_context'] as Map<String, dynamic>?;
    final rolesList = (json['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['employee'];

    final fName = json['first_name'] as String? ?? '';
    final lName = json['last_name'] as String? ?? '';
    var name = json['name'] as String? ?? '';
    if (name.isEmpty) {
      name = '$fName $lName'.trim();
      if (name.isEmpty) {
        name = json['username'] as String? ?? 'User';
      }
    }

    return AuthUserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: fName,
      lastName: lName,
      fullName: name,
      roles: rolesList,
      hasWorkspaceAccess: accessContext?['has_workspace_access'] as bool? ??
          json['has_workspace_access'] as bool? ??
          true,
      defaultRedirect: accessContext?['default_redirect'] as String? ??
          json['default_redirect'] as String? ??
          'workspace',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'name': fullName,
      'roles': roles,
      'access_context': {
        'has_workspace_access': hasWorkspaceAccess,
        'default_redirect': defaultRedirect,
      },
    };
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        fullName,
        roles,
        hasWorkspaceAccess,
        defaultRedirect,
      ];
}
