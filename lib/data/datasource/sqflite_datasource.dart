import 'dart:convert';
import 'dart:ffi';
import 'package:splitemate/models/activity.dart';
import 'package:splitemate/models/transaction.dart' as tra;
import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';

class SqfliteDatasource implements IDatasource {
  final Database _db;

  const SqfliteDatasource(this._db);

  @override
  Future<void> addLedger(Ledger ledger) async {
    await _db.insert(
      'ledger',
      ledger.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> addTransaction(TransactionWrapper transactionWrapper) async {
    tra.Transaction currentTransaction = transactionWrapper.transaction;
    await _db.transaction((txn) async {
      List<Map<String, dynamic>> transactionList =
          transactionWrapper.generateLedgerWiseTransactions();

      bool isParticipantCreated = false;

      await txn.delete('transactions',
          where: 'id = ?', whereArgs: [transactionWrapper.transaction.id]);
      for (var transaction in transactionList) {
        if (!isParticipantCreated) {
          List<Map<String, dynamic>> splitParticipantList = currentTransaction
              .splitDetails
              .map((splitDetail) => splitDetail.getSplitDetailsTableValue())
              .toList();

          for (var sDetails in splitParticipantList) {
            sDetails['transaction_id'] = currentTransaction.id;
            await txn.insert(
              'split_details',
              sDetails,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          isParticipantCreated = true;
        }

        await txn.insert(
          'transactions',
          transaction,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.update(
          'ledger',
          {'updated_at': transactionWrapper.transaction.updatedAt.toString()},
          where: 'id = ? AND type = ?',
          whereArgs: [transaction['ledger_id'], transaction['ledger_type']],
        );
      }
    });
  }

  @override
  Future<void> deleteLedger(String ledgerId, LedgerType ledgerType) async {
    await _db.transaction((txn) async {
      await txn.delete('transactions',
          where: 'ledger_id = ?', whereArgs: [ledgerId]);
      await txn.delete('ledger',
          where: 'id = ? AND type = ?',
          whereArgs: [ledgerId, ledgerType.value()]);
    });
  }

  @override
  Future<List<Ledger>> findAllLedgers(LedgerType ledgerType) async {
    String typeValue = ledgerType.value();

    final listOfLedgerMaps = await _db.query(
      'ledger',
      where: 'type = ?',
      whereArgs: [typeValue],
      orderBy: 'updated_at DESC',
    );

    if (listOfLedgerMaps.isEmpty) return [];

    return await Future.wait(
      listOfLedgerMaps.map<Future<Ledger>>((row) async {
        final unread = Sqflite.firstIntValue(await _db.rawQuery(
                'SELECT COUNT(*) FROM transactions WHERE ledger_id = ? AND receipt = ?',
                [row['id'], 'delivered'])) ??
            0;

        final mostRecentTransaction = await _db.query('transactions',
            where: 'ledger_id = ?',
            whereArgs: [row['id']],
            orderBy: 'created_at DESC',
            limit: 1);

        List<User> users = await fetchUsersFromJson(row['members'] as String);

        final ledger = Ledger.fromMap(row, users);
        ledger.unread = unread;
        //
        // if (mostRecentTransaction.isNotEmpty) {
        //   ledger.mostRecent =
        //       LocalTransaction.fromMap(mostRecentTransaction.first);
        // }

        return ledger;
      }),
    );
  }

  @override
  Future<Ledger?> findLedger(String ledgerId, String ledgerType) async {
    final listOfLedgerMaps = await _db.query(
      'ledger',
      where: 'id = ? AND type = ?',
      whereArgs: [ledgerId, ledgerType],
    );

    if (listOfLedgerMaps.isEmpty) return null;

    final unread = Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE ledger_id = ? AND receipt = ?',
            [ledgerId, 'delivered'])) ??
        0;

    final mostRecentTransaction = await _db.query('transactions',
        where: 'ledger_id = ?',
        whereArgs: [ledgerId],
        orderBy: 'created_at DESC',
        limit: 1);

    List<User> users =
        await fetchUsersFromJson(listOfLedgerMaps.first['members'] as String);

    final ledger = Ledger.fromMap(listOfLedgerMaps.first, users);
    ledger.unread = unread;

    if (mostRecentTransaction.isNotEmpty) {
      ledger.mostRecent = LocalTransaction.fromMap(mostRecentTransaction.first);
    }

    return ledger;
  }

  @override
  Future<Ledger> getLedger(String ledgerId, String ledgerType) async {
    final listOfLedgerMaps = await _db.query(
      'ledger',
      where: 'id = ? AND type = ?',
      whereArgs: [ledgerId, ledgerType],
    );

    final unread = Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE ledger_id = ? AND receipt = ?',
            [ledgerId, 'delivered'])) ??
        0;

    final mostRecentTransaction = await _db.query('transactions',
        where: 'ledger_id = ?',
        whereArgs: [ledgerId],
        orderBy: 'created_at DESC',
        limit: 1);

    List<User> users =
        await fetchUsersFromJson(listOfLedgerMaps.first['members'] as String);

    final ledger = Ledger.fromMap(listOfLedgerMaps.first, users);
    ledger.unread = unread;

    if (mostRecentTransaction.isNotEmpty) {
      ledger.mostRecent = LocalTransaction.fromMap(mostRecentTransaction.first);
    }

    return ledger;
  }

  @override
  Future<List<LocalTransaction>> findTransaction(
      String transactionId, LedgerType ledgerType) async {
    List<Map<String, dynamic>> listOfMaps;

    if (ledgerType == LedgerType.group) {
      listOfMaps = await _db.query(
        'transactions',
        where: 'ledger_id = ? AND ledger_type = ?',
        whereArgs: [transactionId, ledgerType.value()],
      );
    } else {
      listOfMaps = await _db.rawQuery('''
      SELECT DISTINCT t.*
      FROM transactions t
      LEFT JOIN split_details sd ON t.id = sd.transaction_id
      WHERE (t.ledger_id = ? AND t.ledger_type = 'individual') 
         OR (sd.user_id = ? AND t.ledger_type = 'group')
    ''', [transactionId, transactionId]);
    }

    List<Map<String, dynamic>> mutableList =
        listOfMaps.map((map) => Map<String, dynamic>.from(map)).toList();

    for (var transaction in mutableList) {
      transaction['split_details'] =
          await getTransactionParticipants(transaction['id'].toString());
    }

    return mutableList
        .map<LocalTransaction>((map) => LocalTransaction.fromMap(map))
        .toList();
  }

  @override
  Future<void> updateTransaction(LocalTransaction transaction) async {
    await _db.update('transactions', transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.transaction.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTransactionReceipt(
      String transactionId, ReceiptStatus status) async {
    await _db.update('transactions', {'receipt': status.value()},
        where: 'id = ?',
        whereArgs: [transactionId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateExistingLedger(Ledger ledger) async {
    await _db.update('ledger', ledger.toMap(),
        where: 'id = ? AND type = ?',
        whereArgs: [ledger.id, ledger.type.value()],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> fetchUsersFromJson(String membersJson) async {
    List<String> usrIds = [];

    try {
      usrIds = (jsonDecode(membersJson) as List<dynamic>)
          .map((item) => item.toString())
          .toList();
    } catch (e) {
      print('Error decoding members JSON: $e');
    }

    return await fetchUsersByIds(usrIds);
  }

  @override
  Future<void> insertUsers(List<User> users) async {
    await _db.transaction((txn) async {
      for (var user in users) {
        await txn.insert(
          'user',
          {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'image_url': user.imageUrl,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<User>> fetchUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(', ');
    final result = await _db.rawQuery(
      'SELECT * FROM user WHERE id IN ($placeholders)',
      ids,
    );

    return result.map((map) => User.fromJson(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getTransactionParticipants(
      String transactionId) async {
    final db = _db;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
        u.id AS user_id, 
        u.name AS user_name, 
        u.email AS user_email, 
        u.image_url AS user_image, 
        s.amount AS split_amount
    FROM split_details s
    LEFT JOIN user u ON s.user_id = u.id
    WHERE s.transaction_id = ?;
  ''', [transactionId]);
    return result.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<void> addActivity(Activity activity) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'activity',
        activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Activity Added');
    });
  }

  @override
  Future<List<Activity>> findAllActivities() async {
    final listOfActivityMap = await _db.query(
      'activity',
      orderBy: 'created_date DESC',
    );
    return await Future.wait(listOfActivityMap.map((row) async {
      Activity activity = Activity.fromMap(row);
      return activity;
    }));
  }

  @override
  Future<int> getLatestActivity() async {
    final result = await _db.rawQuery('SELECT MAX(id) AS max_id FROM activity');
    if (result.isNotEmpty && result.first['max_id'] != null) {
      return int.tryParse(result.first['max_id'].toString()) ?? 0;
    }
    return 0;
  }

  @override
  Future<void> addBulkTransactions(
      List<TransactionWrapper> transactionWrapperList) async {
    final Map<String, User> uniqueUsersMap = {};
    final Map<String, Ledger> uniqueLedgersMap = {};
    final List<Map<String, dynamic>> transactionRows = [];
    final List<Map<String, dynamic>> splitDetailsRows = [];

    for (var tw in transactionWrapperList) {
      for (var user in tw.members) {
        if (user.id != null) {
          uniqueUsersMap[user.id!] = user;
        }
      }

      if (tw.transaction.groupId.isNotEmpty) {
        final Ledger groupLedger = Ledger(
          tw.transaction.groupId,
          LedgerType.group,
          members: tw.groupInfo.groupParticipants,
          name: tw.groupInfo.name,
          amount: 0,
          createdAt: tw.transaction.createdAt,
          updatedAt: tw.transaction.updatedAt,
        );
        final ledgerKey = '${groupLedger.id}_${groupLedger.type.value()}';
        uniqueLedgersMap[ledgerKey] = groupLedger;
      } else {
        for (var lb in tw.ledgerBalance) {
          final Ledger individualLedger = Ledger(
            lb.id,
            LedgerType.individual,
            members: tw.members,
            name: lb.name,
            amount: lb.balance,
            createdAt: tw.transaction.createdAt,
            updatedAt: tw.transaction.updatedAt,
          );
          final ledgerKey =
              '${individualLedger.id}_${individualLedger.type.value()}';
          uniqueLedgersMap[ledgerKey] = individualLedger;
        }
      }

      final List<Map<String, dynamic>> ledgerWiseTxns =
          tw.generateLedgerWiseTransactions();
      transactionRows.addAll(ledgerWiseTxns);

      for (var splitDetail in tw.transaction.splitDetails) {
        final splitRow = <String, dynamic>{
          'transaction_id': tw.transaction.id,
          'user_id': splitDetail.id,
          'amount': splitDetail.amount,
        };
        splitDetailsRows.add(splitRow);
      }
    }
    await _db.transaction((txn) async {
      for (var user in uniqueUsersMap.values) {
        await txn.insert(
          'user',
          {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'image_url': user.imageUrl,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (var ledger in uniqueLedgersMap.values) {
        await txn.insert(
          'ledger',
          ledger.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (var txnMap in transactionRows) {
        await txn.insert(
          'transactions',
          txnMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final ledgerId = txnMap['ledger_id'] as String;
        final ledgerType = txnMap['ledger_type'] as String;
        final updatedAt = txnMap['updated_at'] as String;
        await txn.update(
          'ledger',
          {'updated_at': updatedAt},
          where: 'id = ? AND type = ?',
          whereArgs: [ledgerId, ledgerType],
        );
      }

      for (var splitMap in splitDetailsRows) {
        await txn.insert(
          'split_details',
          splitMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
