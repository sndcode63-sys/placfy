import 'package:equatable/equatable.dart';

enum CandidateStage { screening, round1, round2, offerExtended, onboarded }

class CandidateModel extends Equatable {
  final String id;
  final String name;
  final String appliedRole;
  final String experienceYears;
  final int aiMatchScore; // e.g. 96%
  final CandidateStage stage;
  final String videoScreeningStatus; // 'Completed', 'Scheduled', 'Pending'
  final String interviewDate;
  final double proctorTrustScore; // e.g. 98.5%

  const CandidateModel({
    required this.id,
    required this.name,
    required this.appliedRole,
    required this.experienceYears,
    required this.aiMatchScore,
    required this.stage,
    required this.videoScreeningStatus,
    required this.interviewDate,
    this.proctorTrustScore = 98.0,
  });

  String get stageName {
    switch (stage) {
      case CandidateStage.screening:
        return 'AI Screening';
      case CandidateStage.round1:
        return 'Round 1 (Tech)';
      case CandidateStage.round2:
        return 'Round 2 (Managerial)';
      case CandidateStage.offerExtended:
        return 'Offer Extended';
      case CandidateStage.onboarded:
        return 'Onboarded';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        appliedRole,
        experienceYears,
        aiMatchScore,
        stage,
        videoScreeningStatus,
        interviewDate,
        proctorTrustScore,
      ];
}
