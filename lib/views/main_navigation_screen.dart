import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/navigation/navigation_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_background.dart';
import '../core/widgets/brand_mark.dart';
import '../core/widgets/floating_nav_bar.dart';
import '../core/widgets/responsive_layout.dart';
import 'attendance/attendance_leaves_view.dart';
import 'dashboard/employee_dashboard_view.dart';
import 'profile/profile_view.dart';
import 'summary/summary_view.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const _items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    NavItemData(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Summary',
    ),
    NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const _screens = <Widget>[
    EmployeeDashboardView(),
    AttendanceLeavesView(),
    SummaryView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        final index = navState.currentTabIndex.clamp(0, _screens.length - 1).toInt();

        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: AppBackground(
            child: Stack(
              children: [
                Column(
                  children: [
                    _Header(tabIndex: index),
                    Expanded(
                      child: ResponsiveLayout(
                        padding: EdgeInsets.zero,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.02),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey<int>(index),
                            child: _screens[index],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                FloatingNavBar(
                  currentIndex: index,
                  items: _items,
                  onTap: (i) =>
                      context.read<NavigationBloc>().add(ChangeTabEvent(i)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final int tabIndex;
  const _Header({required this.tabIndex});

  static const _titles = ['Home', 'History', 'Summary', 'Profile'];

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ResponsiveLayout(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final auth = authState is Authenticated ? authState : null;
            final workspace = auth?.activeWorkspace.name ?? 'Workspace';
            final fullName = auth?.user.fullName.trim() ?? '';
            final firstName =
                fullName.isEmpty ? '' : fullName.split(' ').first;

            final title = tabIndex == 0
                ? (firstName.isEmpty ? _greeting() : firstName)
                : _titles[tabIndex];
            final subtitle = tabIndex == 0 ? _greeting() : workspace;

            return Row(
              children: [
                const BrandTile(size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tabIndex == 0 ? subtitle : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tabIndex == 0
                            ? const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              )
                            : const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        tabIndex == 0 ? title : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tabIndex == 0
                            ? const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              )
                            : const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (tabIndex != 3)
                  Semantics(
                    button: true,
                    label: 'Open profile',
                    child: GestureDetector(
                      onTap: () => context
                          .read<NavigationBloc>()
                          .add(const ChangeTabEvent(3)),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceField,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          auth?.user.initials ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
