import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_dialog.dart';
import '../attendance/widgets/apply_leave_sheet.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/stop_timer_card.dart';

class EmployeeDashboardView extends StatelessWidget {
  const EmployeeDashboardView({super.key});

  void _refresh(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(const RefreshProfileData());
    final authState = authBloc.state;
    if (authState is Authenticated) {
      context.read<AttendanceBloc>().add(LoadAttendanceEvent(
            workspaceSlug: authState.activeWorkspace.slug,
            entityId: authState.activeEntity?.id,
          ));
    } else {
      context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surfaceSheet,
      onRefresh: () async => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          10,

          20,
          FloatingNavBar.reserve(context),
        ),
        children: [
          const StopTimerCard(),
          const SizedBox(height: 14),
          const _WorkspaceCard(),
          const SectionTitle('Quick actions'),
          QuickActionsGrid(
            onApplyLeave: () =>
                showGlassSheet<void>(context, (_) => const ApplyLeaveSheet()),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) return const SizedBox.shrink();
        final entity = authState.activeEntity?.name;

        return GlassCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _line(
                Icons.business_center_rounded,
                'Workspace',
                authState.activeWorkspace.name,
                AppColors.primary,
              ),
              if (entity != null && entity.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                _line(
                  Icons.account_balance_rounded,
                  'Legal entity',
                  entity,
                  AppColors.accent,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _line(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        IconBadge(icon: icon, color: color, size: 42),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
