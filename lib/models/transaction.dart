import 'dart:convert';

import 'package:splitemate/models/ledger.dart';

enum TransactionType { debt, settlement }

extension TransactionTypeParsing on TransactionType {
  String value() {
    return toString().split('.').last;
  }

  static TransactionType fromString(String? type) {
    return TransactionType.values
        .firstWhere((element) => element.value() == type);
  }
}

class SplitDetail {
  final String id;
  final String name;
  final String email;
  final double amount;
  final String imageUrl;

  SplitDetail(
      {required this.id,
      required this.name,
      required this.email,
      required this.amount,
      required this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'amount': amount,
      'image_url': imageUrl
    };
  }

  Map<String, dynamic> getSplitDetailsTableValue(){
    return{
      'transaction_id': '',
      'user_id': id,
      'amount': amount,
    };
  }
}

class Transaction {
  String? get id => _id;

  set id(String? value) => _id;

  final String payerId;
  final double totalAmount;
  final int splitCount;
  final String description;
  final TransactionType transactionType;
  final DateTime transactionDate;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final LedgerType ledgerType;
  final List<SplitDetail> splitDetails;
  String? _id;
  String groupId;

  Transaction(
      {required this.payerId,
      required this.totalAmount,
      required this.splitCount,
      required this.description,
      required this.transactionType,
      required this.transactionDate,
      required this.createdAt,
      required this.createdBy,
      required this.updatedAt,
      required this.splitDetails,
      required this.groupId,
      required this.ledgerType});

  toJson() => {
        'id': _id,
        'payer_id': payerId,
        'total_amount': totalAmount,
        'split_count': splitCount,
        'description': description,
        'transaction_type': transactionType.value(),
        'transaction_date': transactionDate,
        'created_at': createdAt,
        'created_by': createdBy,
        'updated_at': updatedAt,
        'split_details': jsonEncode(
            splitDetails.map((splitDetail) => splitDetail.toJson()).toList()),
        'group_id': groupId,
        'ledger_type': ledgerType.value()
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    var transaction = Transaction(
        payerId: json['payer_id'],
        totalAmount: json['total_amount'] is String
            ? double.parse(json['total_amount'])
            : json['total_amount'] as double,
        splitCount: json['split_count'] is String
            ? int.parse(json['split_count'])
            : json['split_count'] as int,
        description: json['description'],
        transactionType:
            TransactionTypeParsing.fromString(json['transaction_type']),
        transactionDate: json['transaction_date'],
        createdAt: json['created_at'],
        createdBy: json['created_by'],
        updatedAt: json['updated_at'],
        ledgerType: EnumParsing.fromString(json['ledger_type']),
        splitDetails: (json['split_details'] as List)
            .map((item) => SplitDetail(
                  id: item.id,
                  name: item.name,
                  email: item.email,
                  amount: item.amount,
                  imageUrl: item.imageUrl,
                ))
            .toList(),
        groupId: json['group_id']);

    transaction._id = json['id'];
    return transaction;
  }
}
