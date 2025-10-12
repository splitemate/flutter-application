import 'dart:convert';
import 'package:splitemate/models/ledger.dart' as ledger;
import 'package:splitemate/models/transaction.dart';
import 'package:splitemate/models/receipt.dart';

class LocalTransaction {
  String ledgerId;

  String? get id => _id;
  String? _id;
  
  // ✅ Add setter for _id
  set id(String? value) => _id = value;
  
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
    try {
      final List<dynamic>? splitDetailsJson = json['split_details'];
      final List<SplitDetail> splitDetails = splitDetailsJson != null
          ? splitDetailsJson
              .map((item) => SplitDetail(
                    id: item['user_id'] ?? '',
                    name: item['user_name'] ?? '',
                    email: item['user_email'] ?? '',
                    imageUrl: item['user_image'] ?? '',
                    amount: (item['split_amount'] as num?)?.toDouble() ?? 0.0,
                  ))
              .toList()
          : [];
          
      final transaction = Transaction(
          payerId: json['payer_id'] ?? '',
          totalAmount: json['total_amount'] is String
              ? double.tryParse(json['total_amount']) ?? 0.0
              : (json['total_amount'] as num?)?.toDouble() ?? 0.0,
          splitCount: json['split_count'] is String
              ? int.tryParse(json['split_count']) ?? 0
              : json['split_count'] as int? ?? 0,
          description: json['description'] ?? '',
          transactionType:
              TransactionTypeParsing.fromString(json['transaction_type'] ?? 'debt'),
          transactionDate: DateTime.tryParse(json['transaction_date'] ?? '') ?? DateTime.now(),
          createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
          createdBy: json['created_by'] ?? '',
          updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
          ledgerType: ledger.EnumParsing.fromString(json['ledger_type'] ?? 'individual'),
          splitDetails: splitDetails,
          groupId: json['group_id'] ?? '');

      final localTransaction = LocalTransaction(
          ledgerId: json['ledger_id'] ?? '',
          transaction: transaction,
          receipt: EnumParsing.fromString(json['receipt'] ?? 'delivered'));

      localTransaction._id = json['id'];
      return localTransaction;
    } catch (e) {
      print('Error parsing LocalTransaction from map: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}
