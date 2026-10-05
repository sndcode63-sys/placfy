import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pulse_indicator.dart';
import '../../core/widgets/stat_badge.dart';
import '../../core/widgets/responsive_layout.dart';
import 'widgets/stop_timer_card.dart';
import 'widgets/quick_actions_grid.dart';
import '../attendance/widgets/apply_leave_sheet.dart';

class EmployeeDashboardView extends StatelessWidget {
  const EmployeeDashboardView({super.key});

  void _openApplyLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ApplyLeaveSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const employee = AppConstants.currentEmployee;

    return RefreshIndicator(
      color: AppColors.brandPurple,
      backgroundColor: AppColors.surfaceCard,
      onRefresh: () async {
        final authBloc = context.read<AuthBloc>();
        authBloc.add(RefreshProfileData());
        final authState = authBloc.state;
        if (authState is Authenticated) {
          context.read<AttendanceBloc>().add(LoadAttendanceEvent(
                workspaceSlug: authState.activeWorkspace.slug,
                entityId: authState.activeEntity?.id,
              ));
        } else {
          context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: ResponsiveLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Card
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isAuth = authState is Authenticated;
                  final fullName = isAuth && authState.user.fullName.isNotEmpty
                      ? authState.user.fullName
                      : employee.fullName;
                  final subtitle = isAuth
                      ? '${authState.user.primaryRole.toUpperCase()} • ${authState.activeWorkspace.name}'
                      : '${employee.role} • ${employee.department}';
                  final initials = isAuth ? authState.user.initials : 'AS';

                  return GlassCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.brandPurpleLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.brandPurple
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: AppColors.brandPurple,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    fullName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified,
                                      size: 15, color: AppColors.brandPurple),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                subtitle,
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
                        const StatBadge(
                          label: 'Active',
                          color: AppColors.statusSuccess,
                          icon: Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Mesh live sync banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PulseIndicator(color: AppColors.statusSuccess, size: 6),
                        SizedBox(width: 8),
                        Text(
                          'Relational Mesh Live',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '0ms API Sync Lag • SOC2',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Stop-Timer™ Live Interactive Card
              const StopTimerCard(),

              const SizedBox(height: 12),

              // Shift Progress Bar (Target: 8h 30m)
              BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {
                  const targetSeconds = 8.5 * 3600;
                  final progress = (state.elapsedSeconds / targetSeconds).clamp(0.0, 1.0);
                  final hoursLogged = (state.elapsedSeconds / 3600).toStringAsFixed(1);

                  return GlassCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Shift Progress (Target 8.5h)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% (${hoursLogged}h / 8.5h)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceSubtle,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPurple),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Quick Actions Grid
              QuickActionsGrid(onApplyLeave: () => _openApplyLeaveSheet(context)),

              const SizedBox(height: 18),

              // Recent Attendance Logs Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Attendance Logs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'This Week',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {
                  final logs = state.attendanceLogs.take(3).toList();
                  return Column(
                    children: logs.map((log) {
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                log.status == 'Present' ? Icons.check_circle_outline : Icons.laptop_outlined,
                                size: 18,
                                color: log.status == 'Present'
                                    ? AppColors.statusSuccess
                                    : AppColors.statusInfo,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.date,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'In: ${log.punchInTime}  •  Out: ${log.punchOutTime ?? 'In Progress'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatBadge(
                                  label: log.status,
                                  color: log.status == 'Present'
                                      ? AppColors.statusSuccess
                                      : AppColors.statusInfo,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  log.formattedDuration,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
