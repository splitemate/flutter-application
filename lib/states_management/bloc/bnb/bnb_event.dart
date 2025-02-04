part of 'bnb_bloc.dart';

abstract class BnbEvent extends Equatable {}

class TabChange extends BnbEvent {
  final int tabIndex;

  TabChange({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}

class ToggleButtonPressed extends BnbEvent {
  final int toggleIndex;

  ToggleButtonPressed({required this.toggleIndex});

  @override
  List<Object?> get props => [toggleIndex];
}
