import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/navigation/navigation_bloc.dart';
import '../blocs/preferences/preferences_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/pulse_indicator.dart';
import '../core/widgets/responsive_layout.dart';
import 'dashboard/employee_dashboard_view.dart';
import 'attendance/attendance_leaves_view.dart';
import 'payroll/payroll_view.dart';
import 'talent/talent_pipeline_view.dart';
import 'showcase/placfy_showcase_view.dart';
import 'profile/profile_view.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        final currentIndex = navState.currentTabIndex;

        final List<Widget> screens = [
          const EmployeeDashboardView(),
          const AttendanceLeavesView(),
          const PayrollView(),
          const TalentPipelineView(),
          const PlacfyShowcaseView(),
          const ProfileView(),
        ];

        final List<String> screenTitles = [
          'Workspace Dashboard',
          'Attendance & Leaves',
          'Autonomous Payroll',
          'AI Talent Screening',
          'Placfy Cloud Platform',
          'Employee ID & Settings',
        ];

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight, width: 1.0),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Placfy Official Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/placfy_logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'PLACFY',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.brandPurpleLight,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.2)),
                                ),
                                child: const Text(
                                  'AI HRMS',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            screenTitles[currentIndex],
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Relational Mesh Live badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccessBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.statusSuccessBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PulseIndicator(color: AppColors.statusSuccess, size: 6),
                            SizedBox(width: 6),
                            Text(
                              'Live Mesh',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.statusSuccess,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Currency Switcher Quick Button
                      BlocBuilder<PreferencesBloc, PreferencesState>(
                        builder: (context, prefState) {
                          return GestureDetector(
                            onTap: () {
                              final next = prefState.currency == 'INR' ? 'USD' : 'INR';
                              context.read<PreferencesBloc>().add(SetCurrencyEvent(next));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Text(
                                prefState.currency == 'INR' ? '₹ INR' : '\$ USD',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandPurple,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: ResponsiveLayout(
            padding: EdgeInsets.zero,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(currentIndex),
                child: screens[currentIndex],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1.0),
              ),
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  context.read<NavigationBloc>().add(ChangeTabEvent(index));
                },
                backgroundColor: AppColors.surfaceCard,
                selectedItemColor: AppColors.brandPurple,
                unselectedItemColor: AppColors.textSecondary,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard, color: AppColors.brandPurple),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.schedule_outlined),
                    activeIcon: Icon(Icons.schedule, color: AppColors.brandPurple),
                    label: 'Attendance',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_outlined),
                    activeIcon: Icon(Icons.receipt, color: AppColors.brandPurple),
                    label: 'Payroll',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.groups_outlined),
                    activeIcon: Icon(Icons.groups, color: AppColors.brandPurple),
                    label: 'AI Talent',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.language_outlined),
                    activeIcon: Icon(Icons.language, color: AppColors.brandPurple),
                    label: 'Showcase',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person, color: AppColors.brandPurple),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
