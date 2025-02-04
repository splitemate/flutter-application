import 'package:flutter/foundation.dart';
import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/models/user.dart';

abstract class BaseViewModel {
  final IDatasource _datasource;

  BaseViewModel(this._datasource);

  @protected
  Future<void> addTransaction(TransactionWrapper transactionWrapper) async {
    await updateUsersTable(transactionWrapper.members);
    if (transactionWrapper.transaction.groupId.isNotEmpty) {
      final groupInfo = transactionWrapper.groupInfo;
      final ledger = Ledger(groupInfo.id, transactionWrapper.type,
          members: groupInfo.groupParticipants,
          name: groupInfo.name,
          amount: 0);
      await createNewLedger(ledger);
    } else {
      for (var detail in transactionWrapper.ledgerBalance) {
        final ledger = Ledger(detail.id, transactionWrapper.type,
            members: transactionWrapper.members,
            name: detail.name,
            amount: detail.balance);
        await createNewLedger(ledger);
      }
    }
    await _datasource.addTransaction(transactionWrapper);
  }

  Future<void> createNewLedger(Ledger ledger) async {
    await _datasource.addLedger(ledger);
  }

  Future<Ledger> findExistingLedger(String ledgerId, String ledgerType) async {
    return await _datasource.getLedger(ledgerId, ledgerType);
  }

  Future<void> updateExistingLedger(Ledger ledger) async {
    return await _datasource.updateExistingLedger(ledger);
  }

  Future<void> updateUsersTable(List<User> users) async {
    return await _datasource.insertUsers(users);
  }
}
