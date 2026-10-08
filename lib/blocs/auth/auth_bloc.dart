import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/legal_entity_model.dart';
import '../../models/workspace_model.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository})
      : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SelectWorkspace>(_onSelectWorkspace);
    on<SelectEntity>(_onSelectEntity);
    on<RefreshProfileData>(_onRefreshProfileData);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading(message: 'Checking session...'));
    try {
      final token = await authRepository.storage.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const Unauthenticated());
        return;
      }

      final user = await authRepository.getMe();
      final workspaces = await authRepository.getWorkspaces();
      final savedWorkspaceSlug =
      await authRepository.storage.getActiveWorkspace();

      WorkspaceModel? activeWs;
      if (savedWorkspaceSlug != null && savedWorkspaceSlug.isNotEmpty) {
        activeWs = workspaces.cast<WorkspaceModel?>().firstWhere(
              (w) => w?.slug == savedWorkspaceSlug,
          orElse: () => null,
        );
      }

      // If only one workspace or no specific saved, handle resolution
      if (activeWs == null) {
        if (workspaces.length == 1) {
          activeWs = workspaces.first;
        } else if (workspaces.length > 1) {
          emit(WorkspaceSelectionRequired(user: user, workspaces: workspaces));
          return;
        } else {
          // Fallback workspace
          activeWs = const WorkspaceModel(
            id: 5,
            tenantId: 'bb6d8f1f-8dd2-4d9a-9759-89a05010d7a9',
            name: 'Testing Workspace',
            slug: 'testing-workspace',
          );
        }
      }

      await authRepository.storage.saveActiveWorkspace(activeWs.slug);

      // Resolve Legal Entities
      final entities = await authRepository.getMyEntities(activeWs.slug);
      final savedEntityId = await authRepository.storage.getActiveEntityId();

      LegalEntityModel? activeEntity;
      if (savedEntityId != null) {
        activeEntity = entities.cast<LegalEntityModel?>().firstWhere(
              (e) => e?.id == savedEntityId,
          orElse: () => null,
        );
      }

      if (activeEntity == null && entities.isNotEmpty) {
        activeEntity = entities.firstWhere(
              (e) => e.isDefault,
          orElse: () => entities.first,
        );
      }

      if (activeEntity != null) {
        await authRepository.storage.saveActiveEntity(
          entityId: activeEntity.id,
          entityName: activeEntity.name,
        );
      }

      // Fetch Today Attendance
      final shift = await authRepository.getTodayAttendance(
        activeWs.slug,
        entityId: activeEntity?.id,
      );

      final onboarded = await authRepository.isOnboardedEmployee(
        activeWs.slug,
        entityId: activeEntity?.id,
      );

      emit(Authenticated(
        user: user,
        activeWorkspace: activeWs,
        activeEntity: activeEntity,
        shiftInfo: shift,
        availableWorkspaces: workspaces,
        availableEntities: entities,
        isOnboardedEmployee: onboarded,
      ));
    } catch (e) {
      developer.log('Auth check failed: $e', name: 'AuthBloc');
      await authRepository.storage.clearAll();
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading(message: 'Signing in to Placfy...'));
    try {
      await authRepository.login(
        email: event.email,
        password: event.password,
      );

      final user = await authRepository.getMe();
      final workspaces = await authRepository.getWorkspaces();

      if (workspaces.length == 1) {
        final activeWs = workspaces.first;
        await authRepository.storage.saveActiveWorkspace(activeWs.slug);

        final entities = await authRepository.getMyEntities(activeWs.slug);
        LegalEntityModel? defaultEntity;
        if (entities.isNotEmpty) {
          defaultEntity = entities.firstWhere(
                (e) => e.isDefault,
            orElse: () => entities.first,
          );
          await authRepository.storage.saveActiveEntity(
            entityId: defaultEntity.id,
            entityName: defaultEntity.name,
          );
        }

        final shift = await authRepository.getTodayAttendance(
          activeWs.slug,
          entityId: defaultEntity?.id,
        );

        final onboarded = await authRepository.isOnboardedEmployee(
          activeWs.slug,
          entityId: defaultEntity?.id,
        );

        emit(Authenticated(
          user: user,
          activeWorkspace: activeWs,
          activeEntity: defaultEntity,
          shiftInfo: shift,
          availableWorkspaces: workspaces,
          availableEntities: entities,
          isOnboardedEmployee: onboarded,
        ));
      } else if (workspaces.length > 1) {
        emit(WorkspaceSelectionRequired(user: user, workspaces: workspaces));
      } else {
        // No workspaces available - show error
        emit(const AuthFailure('No active workspace found. Please contact your administrator.'));
      }
    } catch (e) {
      final cleanError = e.toString().replaceFirst('Exception: ', '');
      emit(AuthFailure(cleanError));
    }
  }

  Future<void> _onSelectWorkspace(
      SelectWorkspace event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading(message: 'Switching workspace...'));
    try {
      final user = await authRepository.getMe();
      final workspaces = await authRepository.getWorkspaces();
      final activeWs = event.workspace;
      await authRepository.storage.saveActiveWorkspace(activeWs.slug);

      final entities = await authRepository.getMyEntities(activeWs.slug);
      LegalEntityModel? defaultEntity;
      if (entities.isNotEmpty) {
        defaultEntity = entities.firstWhere(
              (e) => e.isDefault,
          orElse: () => entities.first,
        );
        await authRepository.storage.saveActiveEntity(
          entityId: defaultEntity.id,
          entityName: defaultEntity.name,
        );
      }

      final shift = await authRepository.getTodayAttendance(
        activeWs.slug,
        entityId: defaultEntity?.id,
      );

      final onboarded = await authRepository.isOnboardedEmployee(
        activeWs.slug,
        entityId: defaultEntity?.id,
      );

      emit(Authenticated(
        user: user,
        activeWorkspace: activeWs,
        activeEntity: defaultEntity,
        shiftInfo: shift,
        availableWorkspaces: workspaces,
        availableEntities: entities,
        isOnboardedEmployee: onboarded,
      ));
    } catch (e) {
      emit(AuthFailure('Failed to switch workspace: $e'));
    }
  }

  Future<void> _onSelectEntity(
      SelectEntity event,
      Emitter<AuthState> emit,
      ) async {
    if (state is Authenticated) {
      final current = state as Authenticated;
      await authRepository.storage.saveActiveEntity(
        entityId: event.entity.id,
        entityName: event.entity.name,
      );

      final shift = await authRepository.getTodayAttendance(
        current.activeWorkspace.slug,
        entityId: event.entity.id,
      );

      final onboarded = await authRepository.isOnboardedEmployee(
        current.activeWorkspace.slug,
        entityId: event.entity.id,
      );

      emit(current.copyWith(
        activeEntity: event.entity,
        shiftInfo: shift,
        isOnboardedEmployee: onboarded,
      ));
    }
  }

  Future<void> _onRefreshProfileData(
      RefreshProfileData event,
      Emitter<AuthState> emit,
      ) async {
    if (state is Authenticated) {
      final current = state as Authenticated;
      try {
        final user = await authRepository.getMe();
        final entities =
        await authRepository.getMyEntities(current.activeWorkspace.slug);
        final shift = await authRepository.getTodayAttendance(
          current.activeWorkspace.slug,
          entityId: current.activeEntity?.id,
        );

        final onboarded = await authRepository.isOnboardedEmployee(
          current.activeWorkspace.slug,
          entityId: current.activeEntity?.id,
        );

        emit(current.copyWith(
          user: user,
          availableEntities: entities,
          shiftInfo: shift,
          isOnboardedEmployee: onboarded,
        ));
      } catch (e) {
        developer.log('Refresh profile failed: $e', name: 'AuthBloc');
      }
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading(message: 'Signing out...'));
    await authRepository.logout();
    emit(const Unauthenticated(message: 'You have been logged out.'));
  }
}
