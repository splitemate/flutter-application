import 'package:splitemate/models/activity.dart';
import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/viewmodels/base_view_model.dart';

class ActivitiesViewModel extends BaseViewModel {
  final IDatasource _datasource;

  ActivitiesViewModel(this._datasource) : super(_datasource);

  IDatasource get datasource => _datasource;

  Future<List<Activity>> getActivities() async {
    List<Activity> activity = await _datasource.findAllActivities();
    return activity;
  }

  Future<void> receivedActivity(Activity activity) async {
    await addActivity(activity);
  }
}
