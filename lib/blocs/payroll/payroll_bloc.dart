import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/payslip_model.dart';
import '../../core/constants/app_constants.dart';

// EVENTS
abstract class PayrollEvent extends Equatable {
  const PayrollEvent();
  @override
  List<Object?> get props => [];
}

class SelectPayslipEvent extends PayrollEvent {
  final String payslipId;
  const SelectPayslipEvent(this.payslipId);
  @override
  List<Object?> get props => [payslipId];
}

class DownloadPayslipEvent extends PayrollEvent {
  final String payslipId;
  const DownloadPayslipEvent(this.payslipId);
  @override
  List<Object?> get props => [payslipId];
}

// STATES
class PayrollState extends Equatable {
  final List<PayslipModel> payslips;
  final PayslipModel? selectedPayslip;
  final bool isDownloading;
  final String? notification;

  const PayrollState({
    required this.payslips,
    this.selectedPayslip,
    this.isDownloading = false,
    this.notification,
  });

  PayrollState copyWith({
    List<PayslipModel>? payslips,
    PayslipModel? selectedPayslip,
    bool? isDownloading,
    String? notification,
  }) {
    return PayrollState(
      payslips: payslips ?? this.payslips,
      selectedPayslip: selectedPayslip ?? this.selectedPayslip,
      isDownloading: isDownloading ?? this.isDownloading,
      notification: notification,
    );
  }

  @override
  List<Object?> get props => [
        payslips,
        selectedPayslip,
        isDownloading,
        notification,
      ];
}

// BLOC
class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  PayrollBloc()
      : super(const PayrollState(
          payslips: [],
          selectedPayslip: null,
        )) {
    on<SelectPayslipEvent>((event, emit) {
      if (state.payslips.isEmpty) return;
      final found = state.payslips.firstWhere(
        (p) => p.id == event.payslipId,
        orElse: () => state.payslips.first,
      );
      emit(state.copyWith(selectedPayslip: found));
    });

    on<DownloadPayslipEvent>((event, emit) async {
      if (state.selectedPayslip == null) return;
      emit(state.copyWith(isDownloading: true));
      await Future.delayed(const Duration(milliseconds: 700));
      emit(state.copyWith(
        isDownloading: false,
        notification: 'Digitally signed PDF for ${state.selectedPayslip?.monthYear} downloaded.',
      ));
    });
  }
}
