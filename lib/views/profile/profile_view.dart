import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_dialog.dart';
import '../../models/workspace_model.dart';
import '../auth/login_screen.dart';
import '../auth/workspace_select_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _showLogoutDialog(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => GlassDialog(
        icon: Icons.logout_rounded,
        iconColor: AppColors.statusError,
        title: 'Sign out',
        message: 'Are you sure you want to log out from Placfy?',
        actions: [
          dialogButton('Cancel', () => Navigator.of(dialogCtx).pop(),
              outlined: true),
          dialogButton(
            'Log out',
            () {
              Navigator.of(dialogCtx).pop();
              authBloc.add(const LogoutRequested());
            },
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final auth = state is Authenticated ? state : null;
          final user = auth?.user;
          final workspace = auth?.activeWorkspace;
          final entity = auth?.activeEntity;
          final shift = auth?.shiftInfo;
          final isOnboarded = auth?.isOnboardedEmployee ?? true;
          final List<WorkspaceModel> workspaces =
              auth?.availableWorkspaces ?? const [];

          final fullName = user?.fullName ?? '';
          final email = user?.email ?? '';
          final role = (user?.primaryRole ?? 'employee').toUpperCase();
          final initials = user?.initials ?? '';
          final userId = user != null ? '#USR-${user.id}' : '';

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surfaceSheet,
            onRefresh: () async {
              context.read<AuthBloc>().add(const RefreshProfileData());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                FloatingNavBar.reserve(context),
              ),
              children: [
                _IdCard(
                  fullName: fullName,
                  email: email,
                  role: role,
                  initials: initials,
                  userId: userId,
                ),
                const SectionTitle('Work shift'),
                GlassCard(
                  margin: EdgeInsets.zero,
                  child: _InfoRow(
                    icon: Icons.access_time_filled_rounded,
                    color: AppColors.primary,
                    title: shift?.shiftName ?? 'General Shift',
                    subtitle: 'Hours: ${shift?.formattedHours ?? "09:00 - 18:00"}',
                  ),
                ),
                SectionTitle(isOnboarded ? 'Workspace & legal entity' : 'Workspace'),
                GlassCard(
                  margin: EdgeInsets.zero,
                  onTap: (workspaces.length > 1 && user != null)
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorkspaceSelectScreen(
                                workspaces: workspaces,
                                user: user,
                              ),
                            ),
                          )
                      : null,
                  child: _InfoRow(
                    icon: Icons.business_center_rounded,
                    color: AppColors.accentTeal,
                    title: workspace?.name ?? '-',
                    subtitle: 'Your workspace',
                    trailing: workspaces.length > 1
                        ? const _Pill(label: 'Switch')
                        : null,
                  ),
                ),
                if (isOnboarded && entity != null) ...[
                  const SizedBox(height: 12),
                  GlassCard(
                    margin: EdgeInsets.zero,
                    child: _InfoRow(
                      icon: Icons.account_balance_rounded,
                      color: AppColors.violet,
                      title: entity.name,
                      subtitle: entity.entityCode,
                      trailing: entity.city.isNotEmpty
                          ? _Pill(label: entity.city)
                          : null,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                _SignOutButton(onTap: () => _showLogoutDialog(context)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  final String fullName;
  final String email;
  final String role;
  final String initials;
  final String userId;

  const _IdCard({
    required this.fullName,
    required this.email,
    required this.role,
    required this.initials,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: IgnorePointer(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_rounded,
                        size: 18, color: Colors.white.withValues(alpha: 0.85)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DIGITAL WORKFORCE ID',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    if (userId.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              role,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconBadge(icon: icon, color: color, size: 46),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: AppColors.statusError.withValues(alpha: 0.12),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: AppColors.statusError.withValues(alpha: 0.45),
            ),
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded,
                  size: 19, color: AppColors.statusError),
              SizedBox(width: 8),
              Text(
                'Sign out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.statusError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
