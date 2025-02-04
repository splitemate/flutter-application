part of 'splash_bloc.dart';

class SplashState extends Equatable {
  final int tabIndex;

  const SplashState({required this.tabIndex});

  SplashState copyWith({int? tabIndex}) {
    return SplashState(tabIndex: tabIndex ?? this.tabIndex);
  }

  @override
  List<Object?> get props => [tabIndex];
}
