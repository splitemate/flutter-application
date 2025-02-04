part of 'bnb_bloc.dart';

class BnbState extends Equatable {
  final int tabIndex;
  final int toggleIndex;

  const BnbState({required this.tabIndex, required this.toggleIndex});

  BnbState copyWith({int? tabIndex, int? toggleIndex}) {
    return BnbState(
        tabIndex: tabIndex ?? this.tabIndex,
        toggleIndex: toggleIndex ?? this.toggleIndex);
  }

  @override
  List<Object?> get props => [tabIndex, toggleIndex];
}
