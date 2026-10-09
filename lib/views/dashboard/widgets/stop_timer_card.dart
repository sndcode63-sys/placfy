import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/attendance/attendance_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/error_snack.dart';
import '../../../core/widgets/glass_dialog.dart';
import '../../../core/widgets/pulse_indicator.dart';
import '../../../models/employee_model.dart';
import 'break_dialog.dart';

class StopTimerCard extends StatelessWidget {
  const StopTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listenWhen: (p, c) => p.errorSeq != c.errorSeq && c.errorMessage != null,
      listener: (context, state) {
        // While the break dialog is open it shows the error inline.
        if (breakDialogOpen) return;
        showErrorSnack(context, state.errorTitle, state.errorMessage!);
      },
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          final isActive = state.status == ShiftStatus.active;
          final isPaused = state.status == ShiftStatus.paused;
          final isCompleted = state.status == ShiftStatus.completed;
          final isOnBreak = state.onBreak;
          final busy = state.isProcessing;

          final statusText = isOnBreak
              ? 'On Break'
              : (isActive
                  ? 'Currently Working'
                  : (isPaused
                      ? 'Paused'
                      : (isCompleted ? 'Day Completed' : 'Not Checked In')));

          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDeep.withValues(alpha: 0.45),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: -34,
                  right: -24,
                  child: _DecorCircle(size: 130, alpha: 0.09),
                ),
                const Positioned(
                  bottom: -50,
                  left: -36,
                  child: _DecorCircle(size: 160, alpha: 0.07),
                ),
                const Positioned(
                  top: 110,
                  right: 26,
                  child: _DecorCircle(size: 26, alpha: 0.10),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(statusText, isActive, state),
                      const SizedBox(height: 20),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: isOnBreak ? () => showBreakDialog(context) : null,
                        child: _buildTimer(state, isOnBreak),
                      ),
                      const SizedBox(height: 20),
                      _buildInfo(state),
                      const SizedBox(height: 18),
                      _buildActions(
                        context,
                        state,
                        isOnBreak: isOnBreak,
                        isActive: isActive,
                        isPaused: isPaused,
                        isCompleted: isCompleted,
                        busy: busy,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(String statusText, bool isActive, AttendanceState state) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 14, 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseIndicator(
                  color: Colors.white,
                  isPulsing: isActive,
                  size: 7,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final shift = state.shiftInfo ??
                  (authState is Authenticated ? authState.shiftInfo : null);
              return Text(
                shift?.shiftName ?? 'General Shift',
                maxLines: 1,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Timer ─────────────────────────────────────────────────────────────────
  Widget _buildTimer(AttendanceState state, bool isOnBreak) {
    final limit = isOnBreak ? _breakLimitText(state) : null;
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            isOnBreak ? state.formattedBreakTimer : state.formattedTimer,
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isOnBreak ? (state.activeBreakName ?? 'Break Time') : 'Working Time',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
        if (limit != null) ...[
          const SizedBox(height: 6),
          Text(
            limit,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _breakOver(state)
                  ? const Color(0xFFFDE68A)
                  : Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }

  // ── Info tiles ────────────────────────────────────────────────────────────
  Widget _buildInfo(AttendanceState state) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final shift = state.shiftInfo ??
            (authState is Authenticated ? authState.shiftInfo : null);
        final policy = (shift?.policyName.isNotEmpty ?? false)
            ? shift!.policyName
            : 'Not assigned';
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: shift?.date ??
                        DateTime.now().toString().substring(0, 10),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.schedule_rounded,
                    label: 'Shift',
                    value: shift?.formattedHours ?? '09:00 - 18:00',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoTile(
              icon: Icons.verified_user_outlined,
              label: 'Policy',
              value: policy,
            ),
          ],
        );
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Widget _buildActions(
    BuildContext context,
    AttendanceState state, {
    required bool isOnBreak,
    required bool isActive,
    required bool isPaused,
    required bool isCompleted,
    required bool busy,
  }) {
    final bloc = context.read<AttendanceBloc>();

    if (isOnBreak) {
      return Column(
        children: [
          _ActionButton(
            icon: Icons.play_arrow_rounded,
            label: 'End Break & Resume Work',
            kind: _ActionKind.primary,
            loading: busy,
            onTap: busy ? null : () => bloc.add(BreakEndEvent()),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.logout_rounded,
            label: 'Check Out',
            kind: _ActionKind.danger,
            onTap: busy ? null : () => _confirmPunchOut(context),
          ),
        ],
      );
    }

    if (isActive) {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.pause_rounded,
              label: 'Pause',
              compact: true,
              onTap: busy ? null : () => bloc.add(PauseTimerEvent()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.free_breakfast_rounded,
              label: 'Break',
              compact: true,
              onTap: busy ? null : () => showBreakDialog(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.logout_rounded,
              label: 'Check Out',
              compact: true,
              kind: _ActionKind.danger,
              onTap: busy ? null : () => _confirmPunchOut(context),
            ),
          ),
        ],
      );
    }

    if (isPaused) {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.play_arrow_rounded,
              label: 'Resume',
              compact: true,
              onTap: busy ? null : () => bloc.add(ResumeTimerEvent()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.logout_rounded,
              label: 'Check Out',
              compact: true,
              kind: _ActionKind.danger,
              onTap: busy ? null : () => _confirmPunchOut(context),
            ),
          ),
        ],
      );
    }

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You have checked out for today. Total time: ${state.formattedTimer}.',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _ActionButton(
      icon: Icons.fingerprint_rounded,
      label: 'Check In',
      kind: _ActionKind.primary,
      loading: busy,
      onTap: busy ? null : () => _showCheckInModeDialog(context),
    );
  }

  // ── Break helpers ─────────────────────────────────────────────────────────
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

  // ── Check-in flow ─────────────────────────────────────────────────────────
  void _showCheckInModeDialog(BuildContext context) {
    final bloc = context.read<AttendanceBloc>();
    final authState = context.read<AuthBloc>().state;
    final shift = bloc.state.shiftInfo ??
        (authState is Authenticated ? authState.shiftInfo : null);

    final allowOffice = shift?.allowOfficeCheckin ?? true;
    final allowRemote = shift?.allowRemoteCheckin ?? false;

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

    showDialog<void>(
      context: context,
      builder: (dialogContext) => GlassDialog(
        icon: Icons.fingerprint_rounded,
        title: 'How are you working today?',
        message: 'Choose where you are checking in from.',
        actions: [
          dialogButton('Cancel', () => Navigator.pop(dialogContext),
              outlined: true),
        ],
        child: Column(
          children: [
            if (allowOffice)
              _ModeOption(
                title: 'Office',
                subtitle: officeSubtitle,
                icon: Icons.location_on_rounded,
                onTap: () {
                  Navigator.pop(dialogContext);
                  bloc.add(const StartPunchInEvent(mode: 'office'));
                },
              ),
            if (allowRemote)
              _ModeOption(
                title: 'Remote',
                subtitle: 'Work from home or another location',
                icon: Icons.home_work_rounded,
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showRemoteReasonDialog(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoteReasonDialog(BuildContext context) async {
    final bloc = context.read<AttendanceBloc>();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RemoteReasonDialog(),
    );
    if (reason == null) return;
    bloc.add(StartPunchInEvent(mode: 'remote', remoteReason: reason));
  }

  void _confirmPunchOut(BuildContext context) {
    final bloc = context.read<AttendanceBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => GlassDialog(
        icon: Icons.schedule_rounded,
        iconColor: AppColors.statusWarning,
        title: 'End work session?',
        message: 'Your total working hours will be logged for payroll.',
        actions: [
          dialogButton('Cancel', () => Navigator.pop(dialogContext),
              outlined: true),
          dialogButton(
            'Check Out',
            () {
              Navigator.pop(dialogContext);
              bloc.add(PunchOutEvent());
            },
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

// ═══ Small private widgets ══════════════════════════════════════════════════

class _DecorCircle extends StatelessWidget {
  final double size;
  final double alpha;
  const _DecorCircle({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
          border: Border.all(color: Colors.white.withValues(alpha: alpha)),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ActionKind { primary, glass, danger }

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final _ActionKind kind;
  final bool compact;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.kind = _ActionKind.glass,
    this.compact = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    switch (kind) {
      case _ActionKind.primary:
        bg = Colors.white;
        fg = AppColors.primaryDeep;
        border = Colors.transparent;
        break;
      case _ActionKind.danger:
        bg = const Color(0xFFEF4444).withValues(alpha: 0.28);
        fg = Colors.white;
        border = const Color(0xFFFCA5A5).withValues(alpha: 0.6);
        break;
      case _ActionKind.glass:
        bg = Colors.white.withValues(alpha: 0.16);
        fg = Colors.white;
        border = Colors.white.withValues(alpha: 0.28);
        break;
    }

    final radius = BorderRadius.circular(compact ? 18 : 18);

    final Widget content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : (compact
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 21, color: fg),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: fg),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ));

    return Opacity(
      opacity: onTap == null && !loading ? 0.55 : 1,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            height: compact ? 64 : 54,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surfaceField,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                IconBadge(icon: icon, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoteReasonDialog extends StatefulWidget {
  const _RemoteReasonDialog();

  @override
  State<_RemoteReasonDialog> createState() => _RemoteReasonDialogState();
}

class _RemoteReasonDialogState extends State<_RemoteReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      icon: Icons.home_work_rounded,
      title: 'Remote work reason',
      message: 'Let your manager know why you are working remotely today.',
      actions: [
        dialogButton('Cancel', () => Navigator.pop(context), outlined: true),
        dialogButton(
          'Check In',
          () => Navigator.pop(context, _controller.text.trim()),
        ),
      ],
      child: TextField(
        controller: _controller,
        maxLines: 3,
        style: const TextStyle(
          fontSize: 14.5,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Enter reason for remote work...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surfaceField,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
          ),
        ),
      ),
    );
  }
}
