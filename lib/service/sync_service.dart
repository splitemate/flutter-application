import 'package:splitemate/models/activity.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/service/init_auth.dart';
import 'package:splitemate/data/datasource/datasource_contract.dart';

class SyncService {
  // TODO: Need to optimize this function
  final InitAuthService authService;
  final IDatasource datasource;

  SyncService({
    required this.authService,
    required this.datasource,
  });

  Future<void> syncData() async {
    int lastActivityId = await datasource.getLatestActivity();

    bool hasMore = true;
    int currentSinceId = lastActivityId;

    Set<int> transactionIds = {};

    while (hasMore) {
      final responseData = await authService.fetchActivities(currentSinceId);
      if (responseData == null) {
        break;
      }

      final List<dynamic> results = responseData["activities"] ?? [];
      hasMore = responseData["has_more"] ?? false;
      final int nextSinceId = responseData["next_since_id"] ?? currentSinceId;

      for (var activityData in results) {
        try {
          final activity = Activity.fromMap(activityData);
          final int? transactionId = activity.transactionId.isNotEmpty
              ? int.tryParse(activity.transactionId)
              : null;
          if (transactionId != null) {
            await datasource.addActivity(activity);
            transactionIds.add(transactionId);
          }
        } catch (e) {
          print("Error processing activity: $e");
        }
      }
      currentSinceId = nextSinceId;
    }

    if (transactionIds.isNotEmpty) {
      bool haseMoreTransaction = true;
      int page = 1;
      int limit = 50;
      while (haseMoreTransaction) {
        final responseData =
            await authService.fetchTransactions(transactionIds, limit, page);
        if (responseData == null) {
          break;
        }
        final List<dynamic> results = responseData["transactions"] ?? [];
        haseMoreTransaction = responseData["has_more"] ?? false;
        page += 1;
        List<TransactionWrapper> transactionWrapperList = [];
        for (var txn in results) {
          try {
            final transactionWrapper = TransactionWrapper.fromJson(txn);
            transactionWrapperList.add(transactionWrapper);
          } catch (e) {}
        }
        if (transactionWrapperList.isNotEmpty) {
          datasource.addBulkTransactions(transactionWrapperList);
        }
      }
    }
  }
}
