import 'package:equatable/equatable.dart';
import '../../models/legal_entity_model.dart';
import '../../models/workspace_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SelectWorkspace extends AuthEvent {
  final WorkspaceModel workspace;

  const SelectWorkspace(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

class SelectEntity extends AuthEvent {
  final LegalEntityModel entity;

  const SelectEntity(this.entity);

  @override
  List<Object?> get props => [entity];
}

class RefreshProfileData extends AuthEvent {
  const RefreshProfileData();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
