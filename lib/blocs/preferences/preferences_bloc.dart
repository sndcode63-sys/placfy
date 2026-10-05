import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// EVENTS
abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();
  @override
  List<Object?> get props => [];
}

class SetCurrencyEvent extends PreferencesEvent {
  final String currency; // 'INR' or 'USD'
  const SetCurrencyEvent(this.currency);
  @override
  List<Object?> get props => [currency];
}

class TogglePortalModeEvent extends PreferencesEvent {}

// STATES
class PreferencesState extends Equatable {
  final String currency;
  final String currencySymbol;
  final double conversionRate; // INR to USD rate ~ 0.012
  final bool isShowcaseMode;

  const PreferencesState({
    this.currency = 'INR',
    this.currencySymbol = '₹',
    this.conversionRate = 1.0,
    this.isShowcaseMode = false,
  });

  String formatAmount(double amountInInr) {
    if (currency == 'USD') {
      final inUsd = amountInInr / 84.0;
      return '\$${inUsd.toStringAsFixed(0)}';
    }
    return '₹${amountInInr.toStringAsFixed(0)}';
  }

  PreferencesState copyWith({
    String? currency,
    String? currencySymbol,
    double? conversionRate,
    bool? isShowcaseMode,
  }) {
    return PreferencesState(
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      conversionRate: conversionRate ?? this.conversionRate,
      isShowcaseMode: isShowcaseMode ?? this.isShowcaseMode,
    );
  }

  @override
  List<Object?> get props => [
        currency,
        currencySymbol,
        conversionRate,
        isShowcaseMode,
      ];
}

// BLOC
class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  PreferencesBloc() : super(const PreferencesState()) {
    on<SetCurrencyEvent>((event, emit) {
      if (event.currency == 'USD') {
        emit(state.copyWith(
          currency: 'USD',
          currencySymbol: '\$',
          conversionRate: 1 / 84.0,
        ));
      } else {
        emit(state.copyWith(
          currency: 'INR',
          currencySymbol: '₹',
          conversionRate: 1.0,
        ));
      }
    });

    on<TogglePortalModeEvent>((event, emit) {
      emit(state.copyWith(isShowcaseMode: !state.isShowcaseMode));
    });
  }
}
