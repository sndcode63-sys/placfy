import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/leave/leave_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_dialog.dart';
import '../../core/widgets/stat_badge.dart';
import '../../models/employee_model.dart';
import '../../models/leave_request_model.dart';
import 'widgets/apply_leave_sheet.dart';
import 'widgets/attendence_block_view.dart';

class AttendanceLeavesView extends StatefulWidget {
  const AttendanceLeavesView({super.key});

  @override
  State<AttendanceLeavesView> createState() => _AttendanceLeavesViewState();
}

class _AttendanceLeavesViewState extends State<AttendanceLeavesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    showGlassSheet<void>(context, (_) => const ApplyLeaveSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 6),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceField,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(14),
            indicator: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            tabs: const [
              Tab(height: 42, text: 'Attendance'),
              Tab(height: 42, text: 'Leaves'),
            ],
          ),
        ),
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
    );
  }

  // ── Attendance tab ────────────────────────────────────────────────────────
  Widget _buildAttendanceTab() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final logs = state.attendanceLogs;
        final verified = logs.isEmpty
            ? '--'
            : '${(100 * logs.where((l) => l.geoVerified).length / logs.length).round()}%';

        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surfaceSheet,
          onRefresh: () async {
            context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
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
              Row(
                children: [
                  Expanded(
                    child: _MiniMetricCard(
                      title: 'Present',
                      value: '${state.presentDaysCount}d',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.statusSuccess,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetricCard(
                      title: 'Remote',
                      value: '${state.remoteDaysCount}d',
                      icon: Icons.home_work_rounded,
                      color: AppColors.statusInfo,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetricCard(
                      title: 'Verified',
                      value: verified,
                      icon: Icons.verified_user_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SectionTitle('Attendance history'),
              if (logs.isEmpty)
                const GlassCard(
                  margin: EdgeInsets.zero,
                  child: EmptyState(
                    icon: Icons.access_time_rounded,
                    title: 'No attendance records yet',
                    message: 'Check in from the Home tab to get started.',
                  ),
                )
              else
                ...logs.map(_buildLogCard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogCard(AttendanceRecord log) {
    final status = log.status;
    final s = status.toLowerCase();
    final Color color;
    final IconData icon;
    if (s == 'present') {
      color = AppColors.statusSuccess;
      icon = Icons.fingerprint_rounded;
    } else if (s == 'remote') {
      color = AppColors.statusInfo;
      icon = Icons.wifi_tethering_rounded;
    } else if (s.contains('half')) {
      color = AppColors.statusWarning;
      icon = Icons.timelapse_rounded;
    } else if (s.contains('leave')) {
      color = AppColors.violet;
      icon = Icons.beach_access_rounded;
    } else {
      color = AppColors.textSecondary;
      icon = Icons.event_note_rounded;
    }

    final parsed = DateTime.tryParse(log.date);
    final dateLabel =
        parsed != null ? DateFormat('EEE, dd MMM yyyy').format(parsed) : log.date;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'In ${log.punchInTime}  •  Out ${log.punchOutTime ?? 'Working'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatBadge(label: status, color: color),
              const SizedBox(height: 6),
              Text(
                log.formattedDuration,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Leaves tab ────────────────────────────────────────────────────────────
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

    const palette = [
      AppColors.primary,
      AppColors.accentTeal,
      AppColors.violet,
      AppColors.statusWarning,
    ];

    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surfaceSheet,
          onRefresh: () async {
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
              GlassCard(
                hasGlow: true,
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                onTap: _openApplyLeaveSheet,
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apply for leave',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Send a request to your manager',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 15, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SectionTitle('Leave balances'),
              if (state.balances.isEmpty)
                const GlassCard(
                  margin: EdgeInsets.zero,
                  child: EmptyState(
                    icon: Icons.event_available_rounded,
                    title: 'No leave balances',
                    message: 'Your leave balances will appear here.',
                  ),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: state.balances.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final b = state.balances[i];
                      final color = palette[i % palette.length];
                      final ratio = b.totalAllocated > 0
                          ? (b.remaining / b.totalAllocated).clamp(0.0, 1.0)
                          : 0.0;
                      return SizedBox(
                        width: 156,
                        child: GlassCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.leaveType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${b.remaining.toStringAsFixed(0)} days',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: color,
                                ),
                              ),
                              const Spacer(),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 6,
                                  backgroundColor:
                                      AppColors.borderLight,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${b.used.toStringAsFixed(0)} of ${b.totalAllocated.toStringAsFixed(0)} used',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SectionTitle(
                'Recent requests',
                trailing: Text(
                  '${state.requests.length} total',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (state.requests.isEmpty)
                const GlassCard(
                  margin: EdgeInsets.zero,
                  child: EmptyState(
                    icon: Icons.inbox_rounded,
                    title: 'No leave requests',
                    message: 'Requests you submit will show up here.',
                  ),
                )
              else
                ...state.requests.map(_buildRequestCard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(LeaveRequestModel req) {
    final Color statusColor;
    final String statusText;
    if (req.status == LeaveStatus.approved) {
      statusColor = AppColors.statusSuccess;
      statusText = 'Approved';
    } else if (req.status == LeaveStatus.rejected) {
      statusColor = AppColors.statusError;
      statusText = 'Rejected';
    } else {
      statusColor = AppColors.statusWarning;
      statusText = 'Pending';
    }

    final dateStr =
        '${DateFormat('dd MMM').format(req.startDate)} - ${DateFormat('dd MMM yyyy').format(req.endDate)}';

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  req.leaveType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatBadge(label: statusText, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  size: 15, color: AppColors.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$dateStr  •  ${req.daysCount.toStringAsFixed(req.daysCount % 1 == 0 ? 0 : 1)}d',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          if (req.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              req.reason,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (req.approvedBy != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: AppColors.statusSuccess),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Approved by ${req.approvedBy}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
