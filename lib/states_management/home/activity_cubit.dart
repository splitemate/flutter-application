import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/activity.dart';
import 'package:splitemate/viewmodels/activity_view_model.dart';

class ActivitiesCubit extends Cubit<List<Activity>> {
  final ActivitiesViewModel viewModel;

  ActivitiesCubit(this.viewModel) : super([]);

  Future<void> activities() async {
    final activities = await viewModel.getActivities();
    emit(activities);
  }
}
