import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/leave_request_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../repositories/leave_repository.dart';

// EVENTS
abstract class LeaveEvent extends Equatable {
  const LeaveEvent();
  @override
  List<Object?> get props => [];
}

class LoadLeavesEvent extends LeaveEvent {
  final String? workspaceSlug;
  final int? entityId;
  const LoadLeavesEvent({this.workspaceSlug, this.entityId});
  @override
  List<Object?> get props => [workspaceSlug, entityId];
}

class ApplyLeaveEvent extends LeaveEvent {
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final double daysCount;
  final String reason;

  const ApplyLeaveEvent({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.reason,
  });

  @override
  List<Object?> get props => [leaveType, startDate, endDate, daysCount, reason];
}

class CancelLeaveEvent extends LeaveEvent {
  final String requestId;
  const CancelLeaveEvent(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

// STATES
class LeaveState extends Equatable {
  final List<LeaveBalanceModel> balances;
  final List<LeaveRequestModel> requests;
  final bool isLoading;
  final bool isSubmitting;
  final String? message;
  final String? activeWorkspaceSlug;
  final int? activeEntityId;

  const LeaveState({
    required this.balances,
    required this.requests,
    this.isLoading = false,
    this.isSubmitting = false,
    this.message,
    this.activeWorkspaceSlug,
    this.activeEntityId,
  });

  LeaveState copyWith({
    List<LeaveBalanceModel>? balances,
    List<LeaveRequestModel>? requests,
    bool? isLoading,
    bool? isSubmitting,
    String? message,
    String? activeWorkspaceSlug,
    int? activeEntityId,
  }) {
    return LeaveState(
      balances: balances ?? this.balances,
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: message,
      activeWorkspaceSlug: activeWorkspaceSlug ?? this.activeWorkspaceSlug,
      activeEntityId: activeEntityId ?? this.activeEntityId,
    );
  }

  @override
  List<Object?> get props => [
        balances,
        requests,
        isLoading,
        isSubmitting,
        message,
        activeWorkspaceSlug,
        activeEntityId,
      ];
}

// BLOC
class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _leaveRepository;
  final SecureStorageService _storage;

  LeaveBloc({
    LeaveRepository? leaveRepository,
    SecureStorageService? storage,
  })  : _leaveRepository = leaveRepository ?? LeaveRepository(),
        _storage = storage ?? SecureStorageService(),
        super(const LeaveState(
          balances: [],
          requests: [],
        )) {
    on<LoadLeavesEvent>(_onLoadLeaves);
    on<ApplyLeaveEvent>(_onApplyLeave);
    on<CancelLeaveEvent>(_onCancelLeave);
  }

  Future<void> _onLoadLeaves(
    LoadLeavesEvent event,
    Emitter<LeaveState> emit,
  ) async {
    final slug = event.workspaceSlug ??
        await _storage.getActiveWorkspace() ??
        'testing-workspace';
    final entityId = event.entityId ?? await _storage.getActiveEntityId();

    emit(state.copyWith(
      isLoading: true,
      activeWorkspaceSlug: slug,
      activeEntityId: entityId,
    ));

    try {
      final balances = await _leaveRepository.getLeaveBalances(
        slug,
        entityId: entityId,
      );
      final requests = await _leaveRepository.getLeaveRequests(
        slug,
        entityId: entityId,
      );

      emit(state.copyWith(
        isLoading: false,
        balances: balances.isNotEmpty ? balances : state.balances,
        requests: requests.isNotEmpty ? requests : state.requests,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onApplyLeave(ApplyLeaveEvent event, Emitter<LeaveState> emit) async {
    emit(state.copyWith(isSubmitting: true));

    final slug = state.activeWorkspaceSlug ??
        await _storage.getActiveWorkspace() ??
        'testing-workspace';
    final entityId = state.activeEntityId ?? await _storage.getActiveEntityId();

    final newRequest = await _leaveRepository.submitLeaveRequest(
      slug,
      entityId: entityId,
      leaveType: event.leaveType,
      startDate: event.startDate,
      endDate: event.endDate,
      daysCount: event.daysCount,
      reason: event.reason,
    );

    // Update balances locally
    final updatedBalances = state.balances.map((balance) {
      if (balance.leaveType == event.leaveType) {
        final newUsed = balance.used + event.daysCount;
        final newRemaining = (balance.totalAllocated - newUsed).clamp(0.0, balance.totalAllocated);
        return LeaveBalanceModel(
          leaveType: balance.leaveType,
          totalAllocated: balance.totalAllocated,
          used: newUsed,
          remaining: newRemaining,
        );
      }
      return balance;
    }).toList();

    emit(state.copyWith(
      isSubmitting: false,
      requests: [newRequest, ...state.requests],
      balances: updatedBalances,
      message: 'Leave application submitted to reporting manager successfully!',
    ));
  }

  void _onCancelLeave(CancelLeaveEvent event, Emitter<LeaveState> emit) {
    final updated = state.requests.where((r) => r.id != event.requestId).toList();
    emit(state.copyWith(
      requests: updated,
      message: 'Leave request cancelled.',
    ));
  }
}
