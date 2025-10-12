import 'package:flutter_test/flutter_test.dart';
import 'package:splitemate/models/transaction.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/utils/transaction_calculator.dart';

void main() {
  group('TransactionCalculator Tests', () {
    test('should calculate correct affected amount when user is payer', () {
      // Test case: {1: 500, 3: 500, 5: 500} payer = 3, current user = 3
      final splitDetails = [
        SplitDetail(id: '1', name: 'User1', email: 'user1@test.com', amount: 500, imageUrl: ''),
        SplitDetail(id: '3', name: 'User3', email: 'user3@test.com', amount: 500, imageUrl: ''),
        SplitDetail(id: '5', name: 'User5', email: 'user5@test.com', amount: 500, imageUrl: ''),
      ];
      
      final transaction = Transaction(
        payerId: '3',
        totalAmount: 1500,
        splitCount: 3,
        description: 'Test transaction',
        transactionType: TransactionType.debt,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        createdBy: '3',
        updatedAt: DateTime.now(),
        splitDetails: splitDetails,
        groupId: 'test_group',
        ledgerType: LedgerType.group,
      );
      
      final affectedAmount = TransactionCalculator.calculateAffectedAmount(
        transaction: transaction,
        userId: '3',
      );
      
      // Expected: others pay back (500 + 500) - own share (500) = 1000 - 500 = 500 (incoming)
      expect(affectedAmount, 500);
    });
    
    test('should calculate correct affected amount when user is not payer', () {
      // Test case: {1: 500, 3: 500, 5: 500} payer = 2, current user = 3
      final splitDetails = [
        SplitDetail(id: '1', name: 'User1', email: 'user1@test.com', amount: 500, imageUrl: ''),
        SplitDetail(id: '3', name: 'User3', email: 'user3@test.com', amount: 500, imageUrl: ''),
        SplitDetail(id: '5', name: 'User5', email: 'user5@test.com', amount: 500, imageUrl: ''),
      ];
      
      final transaction = Transaction(
        payerId: '2',
        totalAmount: 1500,
        splitCount: 3,
        description: 'Test transaction',
        transactionType: TransactionType.debt,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        createdBy: '2',
        updatedAt: DateTime.now(),
        splitDetails: splitDetails,
        groupId: 'test_group',
        ledgerType: LedgerType.group,
      );
      
      final affectedAmount = TransactionCalculator.calculateAffectedAmount(
        transaction: transaction,
        userId: '3',
      );
      
      // Expected: -own share = -500 (outgoing)
      expect(affectedAmount, -500);
    });
    
    test('should handle user not found in split details', () {
      final splitDetails = [
        SplitDetail(id: '1', name: 'User1', email: 'user1@test.com', amount: 500, imageUrl: ''),
        SplitDetail(id: '3', name: 'User3', email: 'user3@test.com', amount: 500, imageUrl: ''),
      ];
      
      final transaction = Transaction(
        payerId: '1',
        totalAmount: 1000,
        splitCount: 2,
        description: 'Test transaction',
        transactionType: TransactionType.debt,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        createdBy: '1',
        updatedAt: DateTime.now(),
        splitDetails: splitDetails,
        groupId: 'test_group',
        ledgerType: LedgerType.group,
      );
      
      final affectedAmount = TransactionCalculator.calculateAffectedAmount(
        transaction: transaction,
        userId: '999', // User not in split details
      );
      
      // Expected: 0 (default amount when user not found)
      expect(affectedAmount, 0);
    });
  });
} 