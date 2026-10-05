import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/candidate_model.dart';
import '../../models/workspace_member_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../repositories/workforce_repository.dart';

// EVENTS
abstract class TalentEvent extends Equatable {
  const TalentEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkspaceMembersEvent extends TalentEvent {
  final String? workspaceSlug;
  final int? entityId;
  const LoadWorkspaceMembersEvent({this.workspaceSlug, this.entityId});
  @override
  List<Object?> get props => [workspaceSlug, entityId];
}

class FilterCandidatesByStageEvent extends TalentEvent {
  final CandidateStage? stage;
  const FilterCandidatesByStageEvent(this.stage);
  @override
  List<Object?> get props => [stage];
}

class AdvanceCandidateStageEvent extends TalentEvent {
  final String candidateId;
  const AdvanceCandidateStageEvent(this.candidateId);
  @override
  List<Object?> get props => [candidateId];
}

// STATES
class TalentState extends Equatable {
  final List<CandidateModel> candidates;
  final List<WorkspaceMemberModel> members;
  final CandidateStage? selectedStage;
  final String? alertMessage;
  final bool isLoadingMembers;

  const TalentState({
    required this.candidates,
    this.members = const [],
    this.selectedStage,
    this.alertMessage,
    this.isLoadingMembers = false,
  });

  List<CandidateModel> get filteredList {
    if (selectedStage == null) return candidates;
    return candidates.where((c) => c.stage == selectedStage).toList();
  }

  TalentState copyWith({
    List<CandidateModel>? candidates,
    List<WorkspaceMemberModel>? members,
    CandidateStage? selectedStage,
    bool clearFilter = false,
    String? alertMessage,
    bool? isLoadingMembers,
  }) {
    return TalentState(
      candidates: candidates ?? this.candidates,
      members: members ?? this.members,
      selectedStage: clearFilter ? null : (selectedStage ?? this.selectedStage),
      alertMessage: alertMessage,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
    );
  }

  @override
  List<Object?> get props => [
        candidates,
        members,
        selectedStage,
        alertMessage,
        isLoadingMembers,
      ];
}

// BLOC
class TalentBloc extends Bloc<TalentEvent, TalentState> {
  final WorkforceRepository _workforceRepository;
  final SecureStorageService _storage;

  TalentBloc({
    WorkforceRepository? workforceRepository,
    SecureStorageService? storage,
  })  : _workforceRepository = workforceRepository ?? WorkforceRepository(),
        _storage = storage ?? SecureStorageService(),
        super(const TalentState(
          candidates: AppConstants.initialCandidates,
          members: [],
          selectedStage: null,
        )) {
    on<LoadWorkspaceMembersEvent>(_onLoadMembers);
    on<FilterCandidatesByStageEvent>((event, emit) {
      if (event.stage == state.selectedStage) {
        emit(state.copyWith(clearFilter: true));
      } else {
        emit(state.copyWith(selectedStage: event.stage));
      }
    });

    on<AdvanceCandidateStageEvent>((event, emit) {
      final updated = state.candidates.map((c) {
        if (c.id == event.candidateId) {
          CandidateStage nextStage = c.stage;
          switch (c.stage) {
            case CandidateStage.screening:
              nextStage = CandidateStage.round1;
              break;
            case CandidateStage.round1:
              nextStage = CandidateStage.round2;
              break;
            case CandidateStage.round2:
              nextStage = CandidateStage.offerExtended;
              break;
            case CandidateStage.offerExtended:
              nextStage = CandidateStage.onboarded;
              break;
            case CandidateStage.onboarded:
              break;
          }
          return CandidateModel(
            id: c.id,
            name: c.name,
            appliedRole: c.appliedRole,
            experienceYears: c.experienceYears,
            aiMatchScore: c.aiMatchScore,
            stage: nextStage,
            videoScreeningStatus: c.videoScreeningStatus,
            interviewDate: c.interviewDate,
            proctorTrustScore: c.proctorTrustScore,
          );
        }
        return c;
      }).toList();

      final advancedCandidate = state.candidates.firstWhere((c) => c.id == event.candidateId);
      emit(state.copyWith(
        candidates: updated,
        alertMessage:
            'Autonomous Pipeline: ${advancedCandidate.name} moved to next round with rubric audit trail.',
      ));
    });
  }

  Future<void> _onLoadMembers(
    LoadWorkspaceMembersEvent event,
    Emitter<TalentState> emit,
  ) async {
    final slug = event.workspaceSlug ??
        await _storage.getActiveWorkspace() ??
        AppConstants.testWorkspaceSlug;
    final entityId = event.entityId ?? await _storage.getActiveEntityId();

    emit(state.copyWith(isLoadingMembers: true));

    try {
      final members = await _workforceRepository.getWorkspaceMembers(
        slug,
        entityId: entityId,
      );
      emit(state.copyWith(
        isLoadingMembers: false,
        members: members,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMembers: false));
    }
  }
}
