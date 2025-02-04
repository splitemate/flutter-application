part of 'splash_bloc.dart';

abstract class SplashEvent extends Equatable {}

class TabChange extends SplashEvent {
  final int tabIndex;

  TabChange({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}
