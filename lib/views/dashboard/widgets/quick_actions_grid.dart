import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/leave/leave_bloc.dart';
import '../../../blocs/navigation/navigation_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/glass_card.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onApplyLeave;

  const QuickActionsGrid({super.key, required this.onApplyLeave});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final onboarded = authState is! Authenticated || authState.isOnboardedEmployee;
    final leaveState = context.watch<LeaveBloc>().state;

    final remaining =
        leaveState.balances.fold<double>(0, (sum, b) => sum + b.remaining);
    final leaveSubtitle = leaveState.balances.isEmpty
        ? 'Request time off'
        : '${remaining.toStringAsFixed(remaining % 1 == 0 ? 0 : 1)} days available';

    void goTo(int tab) =>
        context.read<NavigationBloc>().add(ChangeTabEvent(tab));

    final tiles = <Widget>[
      _ActionTile(
        title: 'History',
        subtitle: 'Attendance logs',
        icon: Icons.history_rounded,
        color: AppColors.primary,
        onTap: () => goTo(1),
      ),
      if (onboarded)
        _ActionTile(
          title: 'Apply leave',
          subtitle: leaveSubtitle,
          icon: Icons.beach_access_rounded,
          color: AppColors.accentTeal,
          onTap: onApplyLeave,
        ),
      _ActionTile(
        title: 'Summary',
        subtitle: 'Hours & stats',
        icon: Icons.insights_rounded,
        color: AppColors.violet,
        onTap: () => goTo(2),
      ),
      _ActionTile(
        title: 'Profile',
        subtitle: 'Account & shift',
        icon: Icons.person_rounded,
        color: AppColors.accentPink,
        onTap: () => goTo(3),
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      final pair = tiles.skip(i).take(2).toList();
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < pair.length; j++) ...[
                  if (j > 0) const SizedBox(width: 12),
                  Expanded(child: pair[j]),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 44),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
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
