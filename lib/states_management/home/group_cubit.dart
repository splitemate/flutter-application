import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/user.dart';

class GroupCubit extends Cubit<List<User>> {
  GroupCubit() : super([]);

  add(User user) {
    state.add(user);
    emit(List.from(state));
  }

  remove(User user) {
    state.removeWhere((ele) => ele.id == user.id);
    emit(List.from(state));
  }
}
