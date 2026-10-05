import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/talent/talent_bloc.dart';
import '../../models/candidate_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_badge.dart';
import '../../core/widgets/responsive_layout.dart';

class TalentPipelineView extends StatelessWidget {
  const TalentPipelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TalentBloc, TalentState>(
      listener: (context, state) {
        if (state.alertMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceCard,
              content: Text(
                state.alertMessage!,
                style: const TextStyle(color: AppColors.brandPurple),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final candidates = state.filteredList;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ResponsiveLayout(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'All (${state.candidates.length})',
                        isSelected: state.selectedStage == null,
                        onTap: () {
                          context.read<TalentBloc>().add(const FilterCandidatesByStageEvent(null));
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'AI Screening',
                        isSelected: state.selectedStage == CandidateStage.screening,
                        onTap: () {
                          context.read<TalentBloc>().add(
                                const FilterCandidatesByStageEvent(CandidateStage.screening),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Round 1 (Tech)',
                        isSelected: state.selectedStage == CandidateStage.round1,
                        onTap: () {
                          context.read<TalentBloc>().add(
                                const FilterCandidatesByStageEvent(CandidateStage.round1),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Round 2 (Manager)',
                        isSelected: state.selectedStage == CandidateStage.round2,
                        onTap: () {
                          context.read<TalentBloc>().add(
                                const FilterCandidatesByStageEvent(CandidateStage.round2),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Offer Extended',
                        isSelected: state.selectedStage == CandidateStage.offerExtended,
                        onTap: () {
                          context.read<TalentBloc>().add(
                                const FilterCandidatesByStageEvent(CandidateStage.offerExtended),
                              );
                        },
                      ),
                    ],
                  ),
                ),

                if (state.members.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Workspace Team Directory',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${state.members.length} Active',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.members.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final member = state.members[index];
                        final initials = member.userFullName.isNotEmpty
                            ? member.userFullName
                                .trim()
                                .split(' ')
                                .map((s) => s.isNotEmpty ? s[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase()
                            : 'U';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.brandPurpleLight,
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandPurple,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    member.userFullName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    member.role.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Candidates List
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.brandPurple,
                    onRefresh: () async {
                      context.read<TalentBloc>().add(const LoadWorkspaceMembersEvent());
                    },
                    child: candidates.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_search_outlined, size: 44, color: AppColors.textMuted),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'No candidates in this pipeline stage.',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final candidate = candidates[index];
                            return _CandidateCard(candidate: candidate);
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPurple : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandPurple : AppColors.borderLight,
          ),
          boxShadow: isSelected ? null : AppColors.cardShadow,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final CandidateModel candidate;

  const _CandidateCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    Color stageColor;
    switch (candidate.stage) {
      case CandidateStage.screening:
        stageColor = AppColors.statusInfo;
        break;
      case CandidateStage.round1:
        stageColor = AppColors.brandPurple;
        break;
      case CandidateStage.round2:
        stageColor = AppColors.statusWarning;
        break;
      case CandidateStage.offerExtended:
        stageColor = AppColors.statusSuccess;
        break;
      case CandidateStage.onboarded:
        stageColor = AppColors.accentTeal;
        break;
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: stageColor.withValues(alpha: 0.25)),
                ),
                child: Center(
                  child: Text(
                    candidate.name
                        .split(' ')
                        .map((n) => n[0])
                        .take(2)
                        .join(),
                    style: TextStyle(
                      color: stageColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${candidate.appliedRole} • ${candidate.experienceYears}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // AI Match Score Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPurpleLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: AppColors.brandPurple),
                    const SizedBox(width: 4),
                    Text(
                      '${candidate.aiMatchScore}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Details row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.videocam_outlined, size: 14, color: AppColors.brandPurple),
                    const SizedBox(width: 6),
                    Text(
                      'Proctor: ${candidate.proctorTrustScore}% Trust',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text(
                      candidate.interviewDate,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Stage Pill & Advance Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatBadge(
                label: candidate.stageName,
                color: stageColor,
              ),
              if (candidate.stage != CandidateStage.onboarded)
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    context.read<TalentBloc>().add(AdvanceCandidateStageEvent(candidate.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.brandPurpleLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Advance Stage',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandPurple,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 12, color: AppColors.brandPurple),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
