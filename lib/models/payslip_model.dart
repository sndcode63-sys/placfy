import 'package:equatable/equatable.dart';

class PayslipModel extends Equatable {
  final String id;
  final String monthYear; // e.g. "August 2026"
  final double basicSalary;
  final double hra;
  final double specialAllowance;
  final double performanceBonus;
  
  // Statutory & Tax Deductions
  final double providentFund; // PF
  final double esi;
  final double professionalTax;
  final double incomeTaxTds; // Section 192 TDS
  
  final String paymentDate;
  final String transactionId;
  final String currency; // 'INR' or 'USD'
  final String status; // 'Disbursed', 'Processing'

  const PayslipModel({
    required this.id,
    required this.monthYear,
    required this.basicSalary,
    required this.hra,
    required this.specialAllowance,
    this.performanceBonus = 0.0,
    required this.providentFund,
    required this.esi,
    required this.professionalTax,
    required this.incomeTaxTds,
    required this.paymentDate,
    required this.transactionId,
    this.currency = 'INR',
    this.status = 'Disbursed',
  });

  double get grossEarnings => basicSalary + hra + specialAllowance + performanceBonus;
  double get totalDeductions => providentFund + esi + professionalTax + incomeTaxTds;
  double get netPay => grossEarnings - totalDeductions;

  @override
  List<Object?> get props => [
        id,
        monthYear,
        basicSalary,
        hra,
        specialAllowance,
        performanceBonus,
        providentFund,
        esi,
        professionalTax,
        incomeTaxTds,
        paymentDate,
        transactionId,
        currency,
        status,
      ];
}
