import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/attendance/attendance_bloc.dart';
import '../../../models/employee_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/pulse_indicator.dart';
import '../../../core/widgets/stat_badge.dart';

class StopTimerCard extends StatelessWidget {
  const StopTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final isActive = state.status == ShiftStatus.active;
        final isPaused = state.status == ShiftStatus.paused;

        final Color borderColor = isActive
            ? AppColors.brandPurple.withValues(alpha: 0.5)
            : (isPaused ? AppColors.statusWarningBorder : AppColors.borderLight);

        return GlassCard(
          hasGlow: isActive,
          borderColor: borderColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Stop-Timer™ + Geo-fence status
              Row(
                children: [
                  PulseIndicator(
                    color: isActive
                        ? AppColors.brandPurple
                        : (isPaused ? AppColors.statusWarning : AppColors.textMuted),
                    isPulsing: isActive,
                    size: 9,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Stop-Timer™ Biometrics',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      context.read<AttendanceBloc>().add(ToggleGeoFenceEvent());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceCard,
                          content: Text(
                            state.isInsideGeoFence
                                ? 'Switched: Outside 120m perimeter (Remote Mode)'
                                : 'Switched: Inside 120m office perimeter',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: StatBadge(
                      label: state.isInsideGeoFence
                          ? '120m (${state.distanceMeters.toStringAsFixed(0)}m)'
                          : 'Outside (${state.distanceMeters.toStringAsFixed(0)}m)',
                      icon: state.isInsideGeoFence ? Icons.verified_user : Icons.location_off,
                      color: state.isInsideGeoFence
                          ? AppColors.statusSuccess
                          : AppColors.statusWarning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Center Timer Display
              Center(
                child: Column(
                  children: [
                    Text(
                      state.formattedTimer,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: 1.5,
                        color: isActive
                            ? AppColors.textPrimary
                            : (isPaused ? AppColors.statusWarning : AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? 'ACTIVE WORK SESSION • EFFECTIVE HOURS'
                          : (isPaused ? 'SESSION PAUSED • BREAK LOGGED' : 'SHIFT SESSION COMPLETED'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isActive
                            ? AppColors.brandPurple
                            : (isPaused ? AppColors.statusWarning : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                children: [
                  if (isActive) ...[
                    Expanded(
                      child: _LightActionButton(
                        label: 'Pause Break',
                        icon: Icons.pause_circle_outline,
                        color: AppColors.statusWarning,
                        bgColor: AppColors.statusWarningBg,
                        borderColor: AppColors.statusWarningBorder,
                        onTap: () => context.read<AttendanceBloc>().add(PauseTimerEvent()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LightActionButton(
                        label: 'End Shift',
                        icon: Icons.stop_circle_outlined,
                        color: AppColors.statusError,
                        bgColor: AppColors.statusErrorBg,
                        borderColor: AppColors.statusErrorBorder,
                        onTap: () => _confirmPunchOut(context),
                      ),
                    ),
                  ] else if (isPaused) ...[
                    Expanded(
                      child: _LightActionButton(
                        label: 'Resume Session',
                        icon: Icons.play_circle_outline,
                        color: Colors.white,
                        bgColor: AppColors.brandPurple,
                        borderColor: AppColors.brandPurple,
                        isFilled: true,
                        onTap: () => context.read<AttendanceBloc>().add(ResumeTimerEvent()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LightActionButton(
                        label: 'End Shift',
                        icon: Icons.stop_circle_outlined,
                        color: AppColors.statusError,
                        bgColor: AppColors.statusErrorBg,
                        borderColor: AppColors.statusErrorBorder,
                        onTap: () => _confirmPunchOut(context),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: _LightActionButton(
                        label: 'Biometric Punch In',
                        icon: Icons.fingerprint,
                        color: Colors.white,
                        bgColor: AppColors.brandPurple,
                        borderColor: AppColors.brandPurple,
                        isFilled: true,
                        onTap: () => context.read<AttendanceBloc>().add(StartPunchInEvent()),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // Real-time Audit Trail banner
              if (state.lastAuditLog != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: AppColors.brandPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.lastAuditLog!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmPunchOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.schedule, color: AppColors.statusWarning, size: 20),
            SizedBox(width: 8),
            Text(
              'End Work Session?',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Your total working hours and biometric status will be cryptographically logged for payroll.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AttendanceBloc>().add(PunchOutEvent());
            },
            child: const Text('Confirm Punch Out'),
          ),
        ],
      ),
    );
  }
}

class _LightActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;
  final bool isFilled;

  const _LightActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: AppColors.brandPurple.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
