import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../blocs/attendance/attendance_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/widgets/pulse_indicator.dart';
import '../../../models/employee_model.dart';

class StopTimerCard extends StatelessWidget {
  const StopTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final isActive = state.status == ShiftStatus.active;
        final isPaused = state.status == ShiftStatus.paused;

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
                        isActive ? 'Currently Working' : (isPaused ? 'Break Time' : 'Not Checked In'),
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
                      final shift = authState is Authenticated ? authState.shiftInfo : null;
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
                      state.formattedTimer,
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Working Time',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date and Shift Info
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final shift = authState is Authenticated ? authState.shiftInfo : null;
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
                        '${shift?.shiftStart ?? '09:00'} - ${shift?.shiftEnd ?? '18:00'}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.policy,
                        'Policy',
                        shift?.policyName ?? 'Standard Attendance Policy',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (isActive) ...[
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
                        onTap: () {},
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
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showCheckInModeDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
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
    final authState = context.read<AuthBloc>().state;
    final shiftInfo = authState is Authenticated ? authState.shiftInfo : null;
    final enabledModes = shiftInfo?.enabledModes ?? ['standard'];

    // Only show modes that are returned by API in enabled_modes array
    // No hardcoded conditions - fully dynamic based on API response

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Check-In Mode',
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
            // Only show modes that are in enabledModes from API
            for (final mode in enabledModes)
              _buildModeOption(
                dialogContext,
                context,
                _getModeTitle(mode),
                _getModeDescription(mode),
                _getModeIcon(mode),
                true,
                mode,
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

  String _getModeTitle(String mode) {
    switch (mode) {
      case 'standard':
        return 'Standard';
      case 'remote':
        return 'Remote';
      case 'geo_fenced':
        return 'Geo-Fenced';
      case 'selfie':
        return 'Selfie';
      default:
        return mode;
    }
  }

  String _getModeDescription(String mode) {
    switch (mode) {
      case 'standard':
        return 'Office check-in with geo-fence verification';
      case 'remote':
        return 'Work from home / remote location';
      case 'geo_fenced':
        return 'Location-based verification';
      case 'selfie':
        return 'Selfie verification required';
      default:
        return 'Check-in mode';
    }
  }

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'standard':
        return Icons.location_on;
      case 'remote':
        return Icons.home_work;
      case 'geo_fenced':
        return Icons.my_location;
      case 'selfie':
        return Icons.camera_alt;
      default:
        return Icons.check_circle;
    }
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
