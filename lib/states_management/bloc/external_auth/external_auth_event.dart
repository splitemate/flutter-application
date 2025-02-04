part of 'external_auth_bloc.dart';

abstract class ExternalAuthEvent extends Equatable {}

class DataSubmitted extends ExternalAuthEvent {
  @override
  List<Object?> get props => [];
}
