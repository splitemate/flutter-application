import 'package:splitemate/models/transaction.dart';

class TransactionCalculator {
  /// Calculates the affected amount for a user in a transaction
  /// 
  /// The affected amount represents how much money the user gains or loses:
  /// - If user is the payer: they pay the total amount but get reimbursed for others' shares
  /// - If user is not the payer: they only pay their own share
  /// 
  /// Returns a positive value for incoming money (green) and negative for outgoing (red)
  static double calculateAffectedAmount({
    required Transaction transaction,
    required String userId,
  }) {
    final splitDetails = transaction.splitDetails;
    final payerId = transaction.payerId;
    
    // Find the user's split detail
    final userSplitDetail = splitDetails.firstWhere(
      (detail) => detail.id == userId,
      orElse: () => SplitDetail(
        id: userId,
        name: '',
        email: '',
        amount: 0.0,
        imageUrl: '',
      ),
    );
    
    final userAmount = userSplitDetail.amount;
    
    if (userId == payerId) {
      // User is the payer
      final othersAmount = splitDetails
          .where((detail) => detail.id != userId)
          .fold(0.0, (sum, detail) => sum + detail.amount);
      
      return othersAmount;
    } else {
      // User is not the payer
      return -userAmount;
    }
  }
} 