import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/transaction.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/models/user.dart';

class LedgerBalance {
  final String id;
  final String name;
  final String email;
  final double balance;

  LedgerBalance({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
  });
}

class GroupInfo {
  final String id;
  final String name;
  final String description;
  final String groupType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<User> groupParticipants;

  GroupInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.groupType,
    required this.createdAt,
    required this.updatedAt,
    required this.groupParticipants,
  });

  static final GroupInfo empty = GroupInfo(
    id: "",
    name: "",
    description: "",
    groupType: "",
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    groupParticipants: [],
  );

  bool get isEmpty => id.isEmpty;

  bool get isNotEmpty => !isEmpty;
}

class TransactionWrapper {
  String? get id => _id;

  final String method;
  final Transaction transaction;
  String? _id;
  late final String ledgerId;
  late final LedgerType type;
  final List<SplitDetail> splitDetails;
  final List<LedgerBalance> ledgerBalance;
  final GroupInfo groupInfo;
  final ReceiptStatus receipt;
  late final List<User> members;
  late final List<String> memberIds;

  TransactionWrapper({
    required this.method,
    required this.transaction,
    this.splitDetails = const [],
    this.ledgerBalance = const [],
    required this.groupInfo,
    String? initialReceipt,
  })  : ledgerId = (transaction.groupId.isNotEmpty)
            ? transaction.groupId
            : transaction.payerId,
        type = (transaction.groupId.isNotEmpty)
            ? LedgerType.group
            : LedgerType.individual,
        receipt = ReceiptStatus.delivered {
    members = _assignMembers();
    memberIds = _assignMemberIds();
  }

  List<User> _assignMembers() {
    if (type == LedgerType.group) {
      return List<User>.from(groupInfo.groupParticipants);
    } else {
      return splitDetails
          .map((detail) => User.fromJson(detail.toJson()))
          .toList();
    }
  }

  List<String> _assignMemberIds() {
    if (type == LedgerType.group) {
      return groupInfo.groupParticipants
          .map((user) => user.id)
          .whereType<String>()
          .toList();
    } else {
      return splitDetails
          .map((detail) => detail.id)
          .whereType<String>()
          .toList();
    }
  }

  factory TransactionWrapper.fromJson(Map<String, dynamic> json) {
    final String isGroupAvailable = json['group'] ?? '';
    LedgerType ledgerType =
        isGroupAvailable.isEmpty ? LedgerType.individual : LedgerType.group;
    Map<String, dynamic> transactionMap = {
      'id': json['id'],
      'payer_id': json['payer'],
      'total_amount': json['total_amount'] is String
          ? double.parse(json['total_amount'])
          : json['total_amount'] as double,
      'split_count': json['split_count'] is String
          ? int.parse(json['split_count'])
          : json['split_count'] as int,
      'description': json['description'],
      'transaction_type': json['transaction_type'],
      'transaction_date': DateTime.parse(json['transaction_date']),
      'created_at': DateTime.parse(json['created_at']),
      'created_by': json['created_by'],
      'updated_at': DateTime.parse(json['updated_at']),
      'split_details': (json['split_details'] as List)
          .map((item) => SplitDetail(
              id: item['id'],
              name: item['name'],
              email: item['email'],
              amount: item['amount'] as double,
              imageUrl: item['image_url'] ?? ''))
          .toList(),
      'group_id': json['group'] ?? '',
      'ledger_type': ledgerType.value()
    };

    final transaction = Transaction.fromJson(transactionMap);

    List<User> listOfUsers = [];

    if (transaction.groupId.isNotEmpty) {
      listOfUsers = (json['split_details'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    }

    GroupInfo? groupInfo;
    if (transaction.groupId.isNotEmpty) {
      final groupDetail = json['group_details'];
      groupInfo = GroupInfo(
        id: transaction.groupId,
        name: groupDetail['group_name'] ?? 'Unknown Group',
        description: groupDetail['description'] ?? '',
        groupType: groupDetail['group_type'] ?? 'unknown',
        createdAt: DateTime.parse(groupDetail['created_at']),
        updatedAt: DateTime.parse(groupDetail['updated_at']),
        groupParticipants: listOfUsers,
      );
    } else {
      groupInfo = GroupInfo.empty;
    }

    final TransactionWrapper transactionWrapper = TransactionWrapper(
      method: json['method'],
      transaction: transaction,
      splitDetails: (json['split_details'] as List)
          .map((item) => SplitDetail(
              id: item['id'],
              name: item['name'],
              email: item['email'],
              amount: item['amount'] as double,
              imageUrl: item['image_url'] ?? ''))
          .toList(),
      ledgerBalance: (json['ledger_balance'] as List)
          .map((item) => LedgerBalance(
                id: item['id'],
                name: item['name'],
                email: item['email'],
                balance: item['balance'] as double,
              ))
          .toList(),
      groupInfo: groupInfo,
    );

    return transactionWrapper;
  }

  Map<String, dynamic> getLocalTransaction() => {
        'id': transaction.id,
        'ledger_id': ledgerId,
        'payer_id': transaction.payerId,
        'total_amount': transaction.totalAmount,
        'split_count': transaction.splitCount,
        'description': transaction.description,
        'transaction_type': transaction.transactionType.value(),
        'transaction_date': transaction.transactionDate.toIso8601String(),
        'created_at': transaction.createdAt.toIso8601String(),
        'created_by': transaction.createdBy,
        'updated_at': transaction.updatedAt.toIso8601String(),
        'group_id': transaction.groupId,
        'receipt': receipt.value(),
      };

  List<Map<String, dynamic>> generateLedgerWiseTransactions() {
    List<Map<String, dynamic>> transactionList = [];

    Map<String, dynamic> ledgerFormat = {
      'id': transaction.id,
      'payer_id': transaction.payerId,
      'total_amount': transaction.totalAmount,
      'split_count': transaction.splitCount,
      'description': transaction.description,
      'transaction_type': transaction.transactionType.value(),
      'transaction_date': transaction.transactionDate.toIso8601String(),
      'created_at': transaction.createdAt.toIso8601String(),
      'created_by': transaction.createdBy,
      'updated_at': transaction.updatedAt.toIso8601String(),
      'group_id': transaction.groupId,
      'ledger_type': transaction.ledgerType.value(),
      'receipt': receipt.value(),
    };

    if (transaction.groupId.isNotEmpty){
      transactionList.add(ledgerFormat);
      ledgerFormat['ledger_id'] = transaction.groupId;
      return transactionList;
    }

    for (var split in splitDetails) {
      Map<String, dynamic> ledgerCopy = Map.from(ledgerFormat);
      ledgerCopy['ledger_id'] = split.id;
      transactionList.add(ledgerCopy);
    }
    return transactionList;
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'payer_id': transaction.payerId,
        'total_amount': transaction.totalAmount,
        'split_count': transaction.splitCount,
        'description': transaction.description,
        'transaction_type': transaction.transactionType.value(),
        'transaction_date': transaction.transactionDate.toIso8601String(),
        'created_at': transaction.createdAt.toIso8601String(),
        'created_by': transaction.createdBy,
        'updated_at': transaction.updatedAt.toIso8601String(),
        'split_details': splitDetails
            .map((detail) => {
                  'id': detail.id,
                  'name': detail.name,
                  'email': detail.email,
                  'amount': detail.amount,
                })
            .toList(),
        'ledger_balance': ledgerBalance
            .map((ledger) => {
                  'id': ledger.id,
                  'name': ledger.name,
                  'email': ledger.email,
                  'balance': ledger.balance,
                })
            .toList(),
      };
}
