import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/repository/auth_repository.dart';

part 'external_auth_event.dart';

part 'external_auth_state.dart';

class ExternalAuthBloc extends Bloc<ExternalAuthEvent, ExternalAuthState> {
  final AuthRepository? authRepo;
  final UserProvider userProvider;

  ExternalAuthBloc({this.authRepo, required this.userProvider})
      : super(const ExternalAuthState()) {
    on<ExternalAuthEvent>((event, emit) async {
      await mapEventToState(event, emit);
    });
  }

  Future mapEventToState(
      ExternalAuthEvent event, Emitter<ExternalAuthState> emit) async {
    if (event is DataSubmitted) {
      emit(state.copyWith(appStatus: OAuthSubmitted()));
      try {
        final user = await authRepo?.externalAuth();
        if (user != null) {
          userProvider.setUser(CurrentUser(
            id: user['id'],
            name: user['name'],
            email: user['email'],
            imageUrl: user['image_url'],
            totalDue: user['balance']['total_due'],
            totalOwed: user['balance']['total_owed'],
            netBalance: user['balance']['net_balance'],
            accessToken: user['tokens']['access'],
            refreshToken: user['tokens']['access'],
          ));
          emit(state.copyWith(appStatus: OAuthRequestSuccess()));
        } else {
          emit(state.copyWith(appStatus: OAuthRequestFailed()));
        }
      } catch (e) {
        emit(state.copyWith(appStatus: OAuthRequestFailed()));
      }
    }
  }
}
