import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/navigation/navigation_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onApplyLeave;

  const QuickActionsGrid({
    super.key,
    required this.onApplyLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: 'Apply Leave',
                subtitle: '8 Days Balance',
                icon: Icons.calendar_today_outlined,
                accentColor: AppColors.brandPurple,
                bgColor: AppColors.brandPurpleLight,
                onTap: onApplyLeave,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                title: 'View Payslip',
                subtitle: 'August 2026',
                icon: Icons.receipt_long_outlined,
                accentColor: AppColors.statusInfo,
                bgColor: AppColors.statusInfoBg,
                onTap: () {
                  context.read<NavigationBloc>().add(const ChangeTabEvent(2));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: 'AI Screening',
                subtitle: '4 Pipeline Tasks',
                icon: Icons.psychology_outlined,
                accentColor: AppColors.accentTeal,
                bgColor: AppColors.accentTealBg,
                onTap: () {
                  context.read<NavigationBloc>().add(const ChangeTabEvent(3));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                title: 'Daily Standup',
                subtitle: '4/4 Completed',
                icon: Icons.checklist_outlined,
                accentColor: AppColors.statusSuccess,
                bgColor: AppColors.statusSuccessBg,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.surfaceCard,
                      content: Text(
                        'Daily standup checklist saved.',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
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
