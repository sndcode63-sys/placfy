import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/navigation/navigation_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pulse_indicator.dart';
import '../../core/widgets/stat_badge.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/responsive_layout.dart';

class PlacfyShowcaseView extends StatefulWidget {
  const PlacfyShowcaseView({super.key});

  @override
  State<PlacfyShowcaseView> createState() => _PlacfyShowcaseViewState();
}

class _PlacfyShowcaseViewState extends State<PlacfyShowcaseView> {
  int _selectedCloudIndex = 0;

  IconData _getCloudIcon(String iconName) {
    switch (iconName) {
      case 'payments':
        return Icons.payments_outlined;
      case 'timer':
        return Icons.timer_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'people_alt':
        return Icons.groups_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      default:
        return Icons.cloud_done_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        ResponsiveLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Relational Mesh live pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        'RELATIONAL MESH LIVE • ZERO BROKEN APIS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.statusSuccess,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hero Banner with Placfy Logo
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/placfy_logo.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'The Autonomous Workforce\n& AI HRMS Operating System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unified gross-to-net payroll, 120m sub-meter biometric attendance, and AI-proctored hiring in a single relational schema.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Enter Live Workspace',
                            icon: Icons.dashboard_customize_outlined,
                            onPressed: () {
                              context.read<NavigationBloc>().add(const ChangeTabEvent(0));
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'View Enterprise Plans',
                            isOutlined: true,
                            icon: Icons.sell_outlined,
                            onPressed: () {
                              _showPricingDialog(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Platform Clouds Header
              const Row(
                children: [
                  Icon(Icons.hub_outlined, color: AppColors.brandPurple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Placfy Platform Clouds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Cloud Selector Chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.placfyClouds.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cloud = AppConstants.placfyClouds[index];
                    final isSelected = index == _selectedCloudIndex;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCloudIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.brandPurple : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.brandPurple : AppColors.borderLight,
                          ),
                          boxShadow: isSelected ? null : AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCloudIcon(cloud['icon'] as String),
                              size: 14,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (cloud['title'] as String).split(' ').first,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Selected Cloud Detail Card
              Builder(
                builder: (context) {
                  final cloud = AppConstants.placfyClouds[_selectedCloudIndex];
                  final List<String> metrics = (cloud['metrics'] as List<dynamic>).cast<String>();

                  return GlassCard(
                    margin: EdgeInsets.zero,
                    borderColor: AppColors.brandPurple.withValues(alpha: 0.3),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPurpleLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_getCloudIcon(cloud['icon'] as String),
                                      color: AppColors.brandPurple, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  cloud['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            StatBadge(label: cloud['badge'] as String, color: AppColors.brandPurple),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cloud['description'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: metrics.map((m) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Center(
                                  child: Text(
                                    m,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brandPurple,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              // Enterprise Integrations Grid
              const Row(
                children: [
                  Icon(Icons.cable_outlined, color: AppColors.brandPurple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Enterprise ERP & Identity Rails',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...AppConstants.integrations.map((item) {
                return GlassCard(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(Icons.sync_alt, size: 18, color: AppColors.brandPurple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              item['type']!,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      StatBadge(label: item['tag']!, color: AppColors.statusInfo),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Trust & Compliance Footer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 16, color: AppColors.brandPurple),
                        SizedBox(width: 6),
                        Text(
                          'Placfy Trust Center • Enterprise Ready',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'SOC 2 Type II Certified • ISO 27001 • GDPR & DPDP Compliant • AES-256 Encryption',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  void _showPricingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.sell_outlined, color: AppColors.brandPurple, size: 20),
            SizedBox(width: 8),
            Text('Placfy Enterprise Pricing',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Mid-Market: ₹149/user/mo (1-click payroll, Stop-Timer™)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 8),
            Text('• Enterprise: Custom SLA, Multi-entity & NetSuite Bi-Directional sync',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 8),
            Text('• Dedicated Account Executive & 24/7 SLA Support',
                style: TextStyle(color: AppColors.brandPurple, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close', style: TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
