import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/leave/leave_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/employee_model.dart';
import '../../models/leave_request_model.dart';

/// Hours & attendance summary, computed from the logs already loaded.
class SummaryView extends StatelessWidget {
  const SummaryView({super.key});

  static String _hm(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final onboarded =
        authState is! Authenticated || authState.isOnboardedEmployee;

    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, att) {
        final logs = att.attendanceLogs;
        final totalSeconds =
            logs.fold<int>(0, (sum, l) => sum + l.totalWorkSeconds);
        final workedDays = logs.where((l) => l.totalWorkSeconds > 0).length;
        final avgSeconds = workedDays == 0 ? 0 : totalSeconds ~/ workedDays;
        final verified = logs.isEmpty
            ? '--'
            : '${(100 * logs.where((l) => l.geoVerified).length / logs.length).round()}%';

        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surfaceSheet,
          onRefresh: () async {
            context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
            context.read<LeaveBloc>().add(const LoadLeavesEvent());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              FloatingNavBar.reserve(context),
            ),
            children: [
              _HeroTotal(
                total: _hm(totalSeconds),
                subtitle: logs.isEmpty
                    ? 'No attendance logged yet'
                    : 'Across ${logs.length} ${logs.length == 1 ? 'day' : 'days'} logged',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.statusSuccess,
                      value: '${att.presentDaysCount}',
                      label: 'Present days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.home_work_rounded,
                      color: AppColors.statusInfo,
                      value: '${att.remoteDaysCount}',
                      label: 'Remote days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.timer_rounded,
                      color: AppColors.violet,
                      value: workedDays == 0 ? '--' : _hm(avgSeconds),
                      label: 'Avg. per day',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.verified_user_rounded,
                      color: AppColors.accent,
                      value: verified,
                      label: 'Location verified',
                    ),
                  ),
                ],
              ),
              const SectionTitle('Recent hours'),
              _HoursChart(logs: logs),
              if (onboarded) ...[
                const SectionTitle('Leave overview'),
                const _LeaveOverview(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HeroTotal extends StatelessWidget {
  final String total;
  final String subtitle;
  const _HeroTotal({required this.total, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL HOURS WORKED',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    total,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: const Icon(Icons.insights_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 40),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursChart extends StatelessWidget {
  final List<AttendanceRecord> logs;
  const _HoursChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    final recent = logs.take(7).toList().reversed.toList();

    if (recent.isEmpty) {
      return const GlassCard(
        margin: EdgeInsets.zero,
        child: EmptyState(
          icon: Icons.bar_chart_rounded,
          title: 'Nothing to chart yet',
          message: 'Your daily hours will appear here after you check in.',
        ),
      );
    }

    final maxSec = recent
        .map((l) => l.totalWorkSeconds)
        .fold<int>(1, (a, b) => b > a ? b : a);
    const chartHeight = 120.0;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final l in recent)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l.totalWorkSeconds == 0
                          ? '-'
                          : (l.totalWorkSeconds / 3600).toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: 20,
                    height: l.totalWorkSeconds == 0
                        ? 4
                        : 8 + (chartHeight - 8) * (l.totalWorkSeconds / maxSec),
                    decoration: BoxDecoration(
                      gradient: l.totalWorkSeconds == 0
                          ? null
                          : AppColors.brandGradient,
                      color: l.totalWorkSeconds == 0
                          ? AppColors.borderLight
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dayLabel(l.date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _dayLabel(String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return '';
    return d.day.toString().padLeft(2, '0');
  }
}

class _LeaveOverview extends StatelessWidget {
  const _LeaveOverview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        final pending =
            state.requests.where((r) => r.status == LeaveStatus.pending).length;

        if (state.balances.isEmpty) {
          return const GlassCard(
            margin: EdgeInsets.zero,
            child: EmptyState(
              icon: Icons.event_available_rounded,
              title: 'No leave data',
              message: 'Your leave balances will appear here.',
            ),
          );
        }

        return GlassCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (var i = 0; i < state.balances.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _BalanceRow(balance: state.balances[i]),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(),
              ),
              Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded,
                      size: 16, color: AppColors.statusWarning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pending == 0
                          ? 'No requests waiting for approval'
                          : '$pending ${pending == 1 ? 'request' : 'requests'} waiting for approval',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final LeaveBalanceModel balance;
  const _BalanceRow({required this.balance});

  @override
  Widget build(BuildContext context) {
    final ratio = balance.totalAllocated > 0
        ? (balance.remaining / balance.totalAllocated).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                balance.leaveType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${balance.remaining.toStringAsFixed(0)} / ${balance.totalAllocated.toStringAsFixed(0)} days',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      ],
    );
  }
}
