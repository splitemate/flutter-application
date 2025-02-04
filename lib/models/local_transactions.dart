import 'dart:convert';
import 'package:splitemate/models/ledger.dart' as ledger;
import 'package:splitemate/models/transaction.dart';
import 'package:splitemate/models/receipt.dart';

class LocalTransaction {
  String ledgerId;

  String? get id => _id;
  String? _id;
  Transaction transaction;
  ReceiptStatus receipt;

  LocalTransaction(
      {required this.ledgerId,
      required this.transaction,
      required this.receipt});

  Map<String, dynamic> toMap() => {
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

  factory LocalTransaction.fromMap(Map<String, dynamic> json) {
    final List<dynamic> parsedJson = json['split_details'];
    final transaction = Transaction(
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
        transactionDate: DateTime.parse(json['transaction_date']),
        createdAt: DateTime.parse(json['created_at']),
        createdBy: json['created_by'],
        updatedAt: DateTime.parse(json['updated_at']),
        ledgerType: ledger.EnumParsing.fromString(json['ledger_type']),
        splitDetails: parsedJson
            .map((item) => SplitDetail(
                  id: item['user_id'],
                  name: item['user_name'],
                  email: item['user_email'],
                  imageUrl: item['user_image'],
                  amount: (item['split_amount'] as num).toDouble(),
                ))
            .toList(),
        groupId: json['group_id']);

    final localTransaction = LocalTransaction(
        ledgerId: json['ledger_id'],
        transaction: transaction,
        receipt: EnumParsing.fromString(json['receipt']));

    localTransaction._id = json['id'];
    return localTransaction;
  }
}
