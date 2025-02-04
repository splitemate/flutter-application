import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitemate/data/datasource/sqflite_datasource.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/transaction.dart' as model;
import 'package:splitemate/models/local_transactions.dart';

import 'sqflite_datasource_test.mocks.dart';

@GenerateMocks([Database, Batch, Transaction])
void main() {
  late SqfliteDatasource sut;
  late MockDatabase database;
  late MockTransaction mockTransaction;
  late MockBatch batch;

  setUp(() {
    database = MockDatabase();
    batch = MockBatch();
    mockTransaction = MockTransaction();
    sut = SqfliteDatasource(database);
  });

  final transaction = model.Transaction(
      payerId: '111',
      totalAmount: 500,
      splitCount: 2,
      description: 'test desc',
      transactionType: model.TransactionType.settlement,
      transactionDate: DateTime.parse("2021-04-01"),
      createdAt: DateTime.now(),
      createdBy: '111',
      updatedAt: DateTime.now());

  test('should perform insert of ledger into the database', () async {
    final ledger = Ledger('123', LedgerType.individual, membersId: [], members: '', name: 'demo', amount: 0.0);

    when(database.transaction(any)).thenAnswer((Invocation invocation) async {
      final transactionCallback = invocation.positionalArguments[0]
          as Future<void> Function(Transaction);
      await transactionCallback(mockTransaction);
      return null;
    });

    when(mockTransaction.insert(
      'ledger',
      ledger.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((_) async => 1);

    await sut.addLedger(ledger);

    verify(database.transaction(any)).called(1);
    verify(mockTransaction.insert(
      'ledger',
      ledger.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });

  test('should perform insert of transaction to the database', () async {
    final localTransaction = LocalTransaction(
      ledgerId: '1234',
      transaction: transaction,
      receipt: ReceiptStatus.sent,
    );

    when(database.transaction(any)).thenAnswer((Invocation invocation) async {
      final transactionCallback = invocation.positionalArguments[0]
          as Future<void> Function(Transaction);
      await transactionCallback(mockTransaction);
      return null;
    });

    when(mockTransaction.insert(
      'transaction',
      localTransaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((_) async => 1);

    when(mockTransaction.update(
      'ledger',
      {'updated_at': transaction.updatedAt.toString()},
      where: 'id = ?',
      whereArgs: [localTransaction.ledgerId],
      conflictAlgorithm: null,
    )).thenAnswer((_) async => 1);

    // await sut.addTransaction(localTransaction);

    verify(database.transaction(any)).called(1);
    verify(mockTransaction.insert(
      'transaction',
      localTransaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);

    verify(mockTransaction.update(
      'ledger',
      {'updated_at': transaction.updatedAt.toString()},
      where: 'id = ?',
      whereArgs: [localTransaction.ledgerId],
      conflictAlgorithm: null,
    )).called(1);
  });

  test('should perform a database query and return transaction', () async {
    final transactionMap = [
      {
        'id': '123',
        'ledger_id': '111',
        'payer_id': '555',
        'total_amount': 1000,
        'split_count': 2,
        'description': 'Test Expanse',
        'transaction_type': model.TransactionType.debt,
        'transaction_date': DateTime.parse("2024-11-01"),
        'created_at': DateTime.parse("2024-11-01"),
        'created_by': '666',
        'updated_at': DateTime.parse("2024-11-01"),
        'group_id': '777',
        'receipt': 'sent',
      }
    ];

    when(database.query(
      'transaction',
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) async => transactionMap);

    var transactions = await sut.findTransaction('111');

    expect(transactions.length, 1);
    expect(transactions.first.id, '123');
    expect(transactions.first.ledgerId, '111');
    expect(transactions.first.transaction.payerId, '555');
    expect(transactions.first.transaction.totalAmount, 1000);
    expect(transactions.first.transaction.splitCount, 2);
    expect(transactions.first.transaction.description, 'Test Expanse');
    expect(transactions.first.transaction.transactionType,
        model.TransactionType.debt);
    expect(transactions.first.transaction.transactionDate,
        DateTime.parse("2024-11-01"));
    expect(
        transactions.first.transaction.createdAt, DateTime.parse("2024-11-01"));
    expect(transactions.first.transaction.createdBy, '666');
    expect(
        transactions.first.transaction.updatedAt, DateTime.parse("2024-11-01"));
    expect(transactions.first.transaction.groupId, '777');
    expect(transactions.first.receipt, ReceiptStatus.sent);

    verify(database.query(
      'transaction',
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).called(1);
  });

  test('should perform database update on transaction', () async {
    final localTransaction = LocalTransaction(
      ledgerId: '1234',
      transaction: transaction,
      receipt: ReceiptStatus.sent,
    );

    when(database.transaction(any)).thenAnswer((Invocation invocation) async {
      final transactionCallback = invocation.positionalArguments[0]
          as Future<void> Function(Transaction);
      await transactionCallback(mockTransaction);
      return null;
    });

    when(database.update(
      'transaction',
      localTransaction.toMap(),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((_) async => 1);

    await sut.updateTransaction(localTransaction);

    verify(database.update('transaction', localTransaction.toMap(),
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .called(1);
  });

  test('should perform database batch delete of ledger', () async {
    const ledgerId = '111';

    when(database.batch()).thenReturn(batch);

    when(batch.delete('transaction',
        where: anyNamed('where'),
        whereArgs: [ledgerId])).thenAnswer((_) async => 1);
    when(batch.delete('ledger',
        where: anyNamed('where'),
        whereArgs: [ledgerId])).thenAnswer((_) async => 1);

    when(batch.commit(noResult: true)).thenAnswer((_) async => []);

    await sut.deleteLedger(ledgerId);

    verifyInOrder([
      database.batch(),
      batch.delete('transaction',
          where: anyNamed('where'), whereArgs: [ledgerId]),
      batch.delete('ledger', where: anyNamed('where'), whereArgs: [ledgerId]),
      batch.commit(noResult: true),
    ]);
  });
}
