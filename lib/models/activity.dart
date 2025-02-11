import 'dart:convert';

class Activity {
  String id;
  String userId;
  String groupId;
  String transactionId;
  String activityType;
  DateTime createdDate;
  List<String> relatedUsersIds;

  Activity({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.transactionId,
    required this.activityType,
    required this.createdDate,
    required this.relatedUsersIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'transaction_id': transactionId,
      'activity_type': activityType,
      'related_users_ids': jsonEncode(relatedUsersIds),
      'create_date': createdDate.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      groupId: map['group_id'] as String,
      transactionId: map['transaction_id'] as String,
      activityType: map['activity_type'] as String,
      relatedUsersIds: List<String>.from(map['related_users_ids']),
      createdDate: DateTime.parse(map['created_date']),
    );
  }
}
