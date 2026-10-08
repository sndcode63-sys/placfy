import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../blocs/attendance/attendance_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/widgets/pulse_indicator.dart';
import '../../../models/employee_model.dart';
import '../../../models/shift_info_model.dart';

class StopTimerCard extends StatelessWidget {
  const StopTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listenWhen: (p, c) => p.errorSeq != c.errorSeq && c.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
      },
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          final isActive = state.status == ShiftStatus.active;
          final isPaused = state.status == ShiftStatus.paused;
          final isCompleted = state.status == ShiftStatus.completed;
          final isOnBreak = state.onBreak;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PulseIndicator(
                          color: Colors.white,
                          isPulsing: isActive,
                          size: 8,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOnBreak ? 'On Break' : (isActive ? 'Currently Working' : (isPaused ? 'Paused' : (isCompleted ? 'Day Completed' : 'Not Checked In'))),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final shift = state.shiftInfo ?? (authState is Authenticated ? authState.shiftInfo : null);
                        return Text(
                          shift?.shiftName ?? 'General Shift',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Timer Display
                Center(
                  child: Column(
                    children: [
                      Text(
                        isOnBreak ? state.formattedBreakTimer : state.formattedTimer,
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOnBreak ? (state.activeBreakName ?? 'Break Time') : 'Working Time',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      if (isOnBreak && _breakLimitText(state) != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _breakLimitText(state)!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _breakOver(state)
                                ? const Color(0xFFFDE68A)
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Date and Shift Info
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final shift = state.shiftInfo ?? (authState is Authenticated ? authState.shiftInfo : null);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date',
                          shift?.date ?? DateTime.now().toString().substring(0, 10),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.access_time,
                          'Shift',
                          shift?.formattedHours ?? '09:00 - 18:00',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.policy,
                          'Policy',
                          (shift?.policyName.isNotEmpty ?? false) ? shift!.policyName : 'Not assigned',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

// Action Buttons
                if (isOnBreak) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isProcessing
                          ? null
                          : () => context.read<AttendanceBloc>().add(BreakEndEvent()),
                      icon: state.isProcessing
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        'End Break & Resume Work',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: _buildLightButton(
                      icon: Icons.logout,
                      label: 'Check Out',
                      onTap: () => _confirmPunchOut(context),
                      isDestructive: true,
                    ),
                  ),
                ] else if (isActive) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildLightButton(
                          icon: Icons.pause,
                          label: 'Pause',
                          onTap: () => context.read<AttendanceBloc>().add(PauseTimerEvent()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLightButton(
                          icon: Icons.free_breakfast,
                          label: 'Break',
                          onTap: () => _showBreakSheet(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLightButton(
                          icon: Icons.logout,
                          label: 'Check Out',
                          onTap: () => _confirmPunchOut(context),
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ),
                ] else if (isPaused) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildLightButton(
                          icon: Icons.play_arrow,
                          label: 'Resume',
                          onTap: () => context.read<AttendanceBloc>().add(ResumeTimerEvent()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLightButton(
                          icon: Icons.logout,
                          label: 'Check Out',
                          onTap: () => _confirmPunchOut(context),
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ),
                ] else if (isCompleted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You have checked out for today. Total time: ${state.formattedTimer}.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isProcessing ? null : () => _showCheckInModeDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: state.isProcessing
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(
                        'Check In',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  bool _breakOver(AttendanceState state) {
    final allowed = state.activeBreakMinutes;
    return allowed != null && state.breakElapsedSeconds > allowed * 60;
  }

  String? _breakLimitText(AttendanceState state) {
    final allowed = state.activeBreakMinutes;
    if (allowed == null) return null;
    final diff = state.breakElapsedSeconds - allowed * 60;
    if (diff <= 0) {
      final left = (-diff / 60).ceil();
      return 'Allowed: $allowed min  •  $left min left';
    }
    return 'Allowed: $allowed min  •  over by ${(diff / 60).ceil()} min';
  }

  /// Popup listing the break types from the policy. Tapping one starts it.
  void _showBreakSheet(BuildContext context) {
    final bloc = context.read<AttendanceBloc>();
    final rules = bloc.state.shiftInfo?.breakRules ?? const <BreakRuleInfo>[];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.free_breakfast,
                          color: Color(0xFFF59E0B), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Take a Break',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your work timer pauses while you are on a break.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (rules.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'No breaks are set up for your shift. Please contact your HR administrator.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  )
                else
                  ...rules.map((rule) => _buildBreakTile(sheetContext, bloc, rule)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakTile(
      BuildContext sheetContext,
      AttendanceBloc bloc,
      BreakRuleInfo rule,
      ) {
    final subtitleParts = <String>[
      if (rule.durationMinutes != null) '${rule.durationMinutes} min',
      if (rule.isPaid == true) 'Paid',
      if (rule.isPaid == false) 'Unpaid',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(sheetContext);
          bloc.add(BreakStartEvent(
            breakRuleId: rule.id,
            breakName: rule.name,
            allowedMinutes: rule.durationMinutes,
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_cafe_outlined,
                  color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleParts.join('  •  '),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Start',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLightButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.15),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckInModeDialog(BuildContext context) {
    final bloc = context.read<AttendanceBloc>();
    final authState = context.read<AuthBloc>().state;
    final shift = bloc.state.shiftInfo ??
        (authState is Authenticated ? authState.shiftInfo : null);

    final allowOffice = shift?.allowOfficeCheckin ?? true;
    final allowRemote = shift?.allowRemoteCheckin ?? false;

    // What the policy will ask for when checking in from the office
    final checks = <String>[
      if (shift?.requireGeo ?? false) 'your location',
      if (shift?.requireSelfie ?? false) 'a selfie',
    ];
    final officeSubtitle = checks.isEmpty
        ? 'Check in from the office'
        : 'Check in from the office (we will verify ${checks.join(' and ')})';

    // Only one choice? Skip the picker.
    if (allowOffice && !allowRemote) {
      bloc.add(const StartPunchInEvent(mode: 'office'));
      return;
    }
    if (!allowOffice && allowRemote) {
      _showRemoteReasonDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'How are you working today?',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allowOffice)
              _buildModeOption(
                dialogContext,
                context,
                'Office',
                officeSubtitle,
                Icons.location_on,
                true,
                'office',
              ),
            if (allowRemote)
              _buildModeOption(
                dialogContext,
                context,
                'Remote',
                'Work from home or another location',
                Icons.home_work,
                true,
                'remote',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(
      BuildContext dialogContext,
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      bool enabled,
      String mode,
      ) {
    return InkWell(
      onTap: enabled
          ? () {
        Navigator.pop(dialogContext);
        if (mode == 'remote') {
          _showRemoteReasonDialog(context);
        } else {
          context.read<AttendanceBloc>().add(StartPunchInEvent(mode: mode));
        }
      }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFF1F5F9)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFF1F5F9),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: enabled ? const Color(0xFF6366F1) : const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (enabled)
              const Icon(Icons.arrow_forward_ios, size: 14, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  void _showRemoteReasonDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remote Work Reason',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Enter reason for remote work...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AttendanceBloc>().add(
                StartPunchInEvent(
                  mode: 'remote',
                  remoteReason: reasonController.text.trim(),
                ),
              );
            },
            child: Text(
              'Check In',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPunchOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.schedule, color: Color(0xFFF59E0B), size: 20),
            const SizedBox(width: 8),
            Text(
              'End Work Session?',
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Your total working hours will be logged for payroll.',
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AttendanceBloc>().add(PunchOutEvent());
            },
            child: Text(
              'Check Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}