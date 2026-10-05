import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/payroll/payroll_bloc.dart';
import '../../blocs/preferences/preferences_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_badge.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/responsive_layout.dart';

class PayrollView extends StatelessWidget {
  const PayrollView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PayrollBloc, PayrollState>(
      listener: (context, state) {
        if (state.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceCard,
              content: Row(
                children: [
                  const Icon(Icons.download_done, color: AppColors.statusSuccess),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.notification!,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, payrollState) {
        return BlocBuilder<PreferencesBloc, PreferencesState>(
          builder: (context, prefState) {
            final payslip = payrollState.selectedPayslip;

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                ResponsiveLayout(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Selector Bar
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: payrollState.payslips.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final p = payrollState.payslips[index];
                            final isSelected = p.id == payslip.id;
                            return GestureDetector(
                              onTap: () {
                                context.read<PayrollBloc>().add(SelectPayslipEvent(p.id));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.brandPurple : AppColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.brandPurple : AppColors.borderLight,
                                  ),
                                  boxShadow: isSelected ? null : AppColors.cardShadow,
                                ),
                                child: Text(
                                  p.monthYear,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Clean Executive Net Pay Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight, width: 1.0),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'NET PAYABLE SALARY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.brandPurple,
                                  ),
                                ),
                                StatBadge(
                                  label: payslip.status.toUpperCase(),
                                  color: AppColors.statusSuccess,
                                  icon: Icons.check_circle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              prefState.formatAmount(payslip.netPay),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Disbursed on ${payslip.paymentDate} • Ref: ${payslip.transactionId}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const Divider(height: 24, color: AppColors.borderLight),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _MiniStat(
                                  title: 'Gross Earnings',
                                  value: prefState.formatAmount(payslip.grossEarnings),
                                  color: AppColors.statusSuccess,
                                ),
                                _MiniStat(
                                  title: 'Deductions',
                                  value: '-${prefState.formatAmount(payslip.totalDeductions)}',
                                  color: AppColors.statusError,
                                ),
                                _MiniStat(
                                  title: 'Currency',
                                  value: prefState.currency,
                                  color: AppColors.brandPurple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Earnings Breakdown
                      const Text(
                        'Earnings Breakdown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            _BreakdownRow(
                              title: 'Basic Salary',
                              subtitle: 'Fixed monthly base pay',
                              amount: prefState.formatAmount(payslip.basicSalary),
                            ),
                            const Divider(color: AppColors.borderLight),
                            _BreakdownRow(
                              title: 'House Rent Allowance (HRA)',
                              subtitle: 'Section 10(13A) Tax Exempted',
                              amount: prefState.formatAmount(payslip.hra),
                            ),
                            const Divider(color: AppColors.borderLight),
                            _BreakdownRow(
                              title: 'Special Allowance',
                              subtitle: 'Flexible benefits pool',
                              amount: prefState.formatAmount(payslip.specialAllowance),
                            ),
                            if (payslip.performanceBonus > 0) ...[
                              const Divider(color: AppColors.borderLight),
                              _BreakdownRow(
                                title: 'Performance Bonus',
                                subtitle: 'Q3 Merit Incentive',
                                amount: prefState.formatAmount(payslip.performanceBonus),
                                highlightColor: AppColors.brandPurple,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Statutory & Tax Deductions
                      const Text(
                        'Statutory & Tax Deductions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            _BreakdownRow(
                              title: 'Provident Fund (EPFO)',
                              subtitle: '12% Statutory Employee Contribution',
                              amount: '-${prefState.formatAmount(payslip.providentFund)}',
                              isDeduction: true,
                            ),
                            const Divider(color: AppColors.borderLight),
                            _BreakdownRow(
                              title: 'Income Tax TDS (Section 192)',
                              subtitle: 'Tax Regime Form 16 Tracked',
                              amount: '-${prefState.formatAmount(payslip.incomeTaxTds)}',
                              isDeduction: true,
                            ),
                            const Divider(color: AppColors.borderLight),
                            _BreakdownRow(
                              title: 'ESI & Professional Tax',
                              subtitle: 'Statutory city council deduction',
                              amount: '-${prefState.formatAmount(payslip.esi + payslip.professionalTax)}',
                              isDeduction: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Download Button
                      CustomButton(
                        text: 'Download Signed Payslip (PDF)',
                        icon: Icons.download_outlined,
                        isLoading: payrollState.isDownloading,
                        onPressed: () {
                          context.read<PayrollBloc>().add(DownloadPayslipEvent(payslip.id));
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniStat({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isDeduction;
  final Color? highlightColor;

  const _BreakdownRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isDeduction = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: highlightColor ?? AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDeduction
                  ? AppColors.statusError
                  : (highlightColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
