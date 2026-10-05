import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object?> get props => [];
}

class ChangeTabEvent extends NavigationEvent {
  final int tabIndex;
  const ChangeTabEvent(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}

// States
class NavigationState extends Equatable {
  final int currentTabIndex;
  const NavigationState({this.currentTabIndex = 0});

  @override
  List<Object?> get props => [currentTabIndex];
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(currentTabIndex: 0)) {
    on<ChangeTabEvent>((event, emit) {
      emit(NavigationState(currentTabIndex: event.tabIndex));
    });
  }
}
