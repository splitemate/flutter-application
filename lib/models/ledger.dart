import 'dart:convert';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/models/local_transactions.dart';

enum LedgerType { individual, group }

extension EnumParsing on LedgerType {
  String value() {
    return toString().split('.').last;
  }

  static LedgerType fromString(String status) {
    return LedgerType.values.firstWhere((element) => element.value() == status);
  }
}

class Ledger {
  late String id;
  late LedgerType type;
  int unread = 0;
  List<LocalTransaction>? messages = [];
  LocalTransaction? mostRecent;
  List<User> members;
  List<String> membersId = [];
  String name;
  String? imageUrl;
  double amount;
  DateTime? createdAt;
  DateTime? updatedAt;

  Ledger(
      this.id,
      this.type, {
        required this.members,
        required this.name,
        required this.amount,
        this.messages,
        this.mostRecent,
        this.createdAt,
        this.updatedAt,
      }) {
    membersId = members.map((user) => user.id ?? '').where((id) => id.isNotEmpty).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.value(),
      'members': jsonEncode(membersId),
      'amount': amount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Ledger.fromMap(Map<String, dynamic> map, List<User> allUsers) {
    List<String> memberIds = List<String>.from(jsonDecode(map['members']));
    List<User> members = allUsers.where((user) => memberIds.contains(user.id)).toList();

    return Ledger(
      map['id'],
      EnumParsing.fromString(map['type']),
      members: members,
      name: map['name'],
      amount: map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
