import 'package:equatable/equatable.dart';
import '../../models/auth_user_model.dart';
import '../../models/legal_entity_model.dart';
import '../../models/shift_info_model.dart';
import '../../models/workspace_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class WorkspaceSelectionRequired extends AuthState {
  final AuthUserModel user;
  final List<WorkspaceModel> workspaces;

  const WorkspaceSelectionRequired({
    required this.user,
    required this.workspaces,
  });

  @override
  List<Object?> get props => [user, workspaces];
}

class Authenticated extends AuthState {
  final AuthUserModel user;
  final WorkspaceModel activeWorkspace;
  final LegalEntityModel? activeEntity;
  final ShiftInfoModel? shiftInfo;
  final List<WorkspaceModel> availableWorkspaces;
  final List<LegalEntityModel> availableEntities;
  /// false for workspace members who are not onboarded employees yet.
  final bool isOnboardedEmployee;

  const Authenticated({
    required this.user,
    required this.activeWorkspace,
    this.activeEntity,
    this.shiftInfo,
    this.availableWorkspaces = const [],
    this.availableEntities = const [],
    this.isOnboardedEmployee = true,
  });

  Authenticated copyWith({
    AuthUserModel? user,
    WorkspaceModel? activeWorkspace,
    LegalEntityModel? activeEntity,
    ShiftInfoModel? shiftInfo,
    List<WorkspaceModel>? availableWorkspaces,
    List<LegalEntityModel>? availableEntities,
    bool? isOnboardedEmployee,
  }) {
    return Authenticated(
      user: user ?? this.user,
      activeWorkspace: activeWorkspace ?? this.activeWorkspace,
      activeEntity: activeEntity ?? this.activeEntity,
      shiftInfo: shiftInfo ?? this.shiftInfo,
      availableWorkspaces: availableWorkspaces ?? this.availableWorkspaces,
      availableEntities: availableEntities ?? this.availableEntities,
      isOnboardedEmployee: isOnboardedEmployee ?? this.isOnboardedEmployee,
    );
  }

  @override
  List<Object?> get props => [
    user,
    activeWorkspace,
    activeEntity,
    shiftInfo,
    availableWorkspaces,
    availableEntities,
    isOnboardedEmployee,
  ];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}
