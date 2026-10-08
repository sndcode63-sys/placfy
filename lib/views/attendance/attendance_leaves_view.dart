import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:placfy/views/attendance/widgets/attendence_block_view.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/leave/leave_bloc.dart';
import '../../models/leave_request_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_badge.dart';
import '../../core/widgets/responsive_layout.dart';
import 'widgets/apply_leave_sheet.dart';

class AttendanceLeavesView extends StatefulWidget {
  const AttendanceLeavesView({super.key});

  @override
  State<AttendanceLeavesView> createState() => _AttendanceLeavesViewState();
}

class _AttendanceLeavesViewState extends State<AttendanceLeavesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openApplyLeaveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ApplyLeaveSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final onboarded = authState is! Authenticated || authState.isOnboardedEmployee;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: !onboarded ? null : FloatingActionButton.extended(
        backgroundColor: AppColors.brandPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('Apply Leave', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        onPressed: _openApplyLeaveSheet,
      ),
      body: ResponsiveLayout(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Sub-navigation Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: AppColors.cardShadow,
                ),
                labelColor: AppColors.brandPurple,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: 'Attendance'),
                  Tab(text: 'Leave Management'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAttendanceTab(),
                  _buildLeavesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.brandPurple,
          onRefresh: () async {
            context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // Monthly Summary Cards Row
              Row(
                children: [
                  Expanded(
                    child: _MiniMetricCard(
                      title: 'Present',
                      value: '${state.presentDaysCount} Days',
                      icon: Icons.check_circle_outline,
                      color: AppColors.statusSuccess,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniMetricCard(
                      title: 'Remote',
                      value: '${state.remoteDaysCount} Days',
                      icon: Icons.home_work_outlined,
                      color: AppColors.statusInfo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniMetricCard(
                      title: 'Location Verified',
                      value: state.attendanceLogs.isEmpty
                          ? '--'
                          : '${(100 * state.attendanceLogs.where((l) => l.geoVerified).length / state.attendanceLogs.length).round()}%',
                      icon: Icons.verified_user_outlined,
                      color: AppColors.brandPurple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'Attendance History',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              if (state.attendanceLogs.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'No attendance records yet',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check in from the Home tab to get started',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ...state.attendanceLogs.map((log) {
                  return GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: log.status == 'Present'
                                ? AppColors.statusSuccessBg
                                : AppColors.statusInfoBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            log.status == 'Present' ? Icons.fingerprint : Icons.wifi_tethering,
                            color: log.status == 'Present' ? AppColors.statusSuccess : AppColors.statusInfo,
                            size: 20,
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
                                'In: ${log.punchInTime} • Out: ${log.punchOutTime ?? 'Working'}',
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
                              color: log.status == 'Present' ? AppColors.statusSuccess : AppColors.statusInfo,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log.formattedDuration,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeavesTab() {
    final authState = context.watch<AuthBloc>().state;
    if (authState is Authenticated && !authState.isOnboardedEmployee) {
      return const AttendanceBlockedView(
        icon: Icons.beach_access_outlined,
        title: 'Leaves not available yet',
        message:
        'Leaves are available once your onboarding is complete. Please contact your HR administrator.',
      );
    }
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.brandPurple,
          onRefresh: () async {
            context.read<LeaveBloc>().add(const LoadLeavesEvent());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              const Text(
                'Available Leave Balances',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: state.balances.map((balance) {
                  final ratio = balance.remaining / balance.totalAllocated;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              balance.leaveType.split(' ').first,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${balance.remaining.toStringAsFixed(0)} Days',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandPurple,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 4,
                                backgroundColor: AppColors.surfaceSubtle,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPurple),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${balance.used.toStringAsFixed(0)} of ${balance.totalAllocated.toStringAsFixed(0)} used',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Leave Requests',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${state.requests.length} Total',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...state.requests.map((req) {
                Color statusColor;
                String statusText;
                if (req.status == LeaveStatus.approved) {
                  statusColor = AppColors.statusSuccess;
                  statusText = 'Approved';
                } else if (req.status == LeaveStatus.rejected) {
                  statusColor = AppColors.statusError;
                  statusText = 'Rejected';
                } else {
                  statusColor = AppColors.statusWarning;
                  statusText = 'Pending Approval';
                }

                final dateStr =
                    '${DateFormat('dd MMM').format(req.startDate)} - ${DateFormat('dd MMM yyyy').format(req.endDate)}';

                return GlassCard(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            req.leaveType,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          StatBadge(
                            label: statusText,
                            color: statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPurple,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        req.reason,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (req.approvedBy != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 12, color: AppColors.statusSuccess),
                            const SizedBox(width: 4),
                            Text(
                              'Approved by: ${req.approvedBy}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
