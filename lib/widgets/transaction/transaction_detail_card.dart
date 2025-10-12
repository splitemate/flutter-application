import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/screens/transaction/transaction_detail_screen.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/widgets/common/unread_count_badge.dart';
import 'package:splitemate/utils/transaction_calculator.dart';

class TransactionDetailCard extends StatelessWidget {
  final LocalTransaction transaction;
  final Ledger ledger;
  final CurrentUser me;
  final Size size;
  final VoidCallback? onOpened;

  const TransactionDetailCard({
    super.key,
    required this.transaction,
    required this.ledger,
    required this.me,
    required this.size,
    this.onOpened,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = transaction.transaction.totalAmount;
    final description = transaction.transaction.description;
    final date = transaction.transaction.transactionDate;
    final isUnread = transaction.receipt == ReceiptStatus.delivered;
    
    // Calculate affected amount for current user
    final affectedAmount = TransactionCalculator.calculateAffectedAmount(
      transaction: transaction.transaction,
      userId: me.id,
    );
    
    // Determine color based on whether money is incoming or outgoing
    final amountColor = affectedAmount >= 0 ? kGreenColor : kRedColor;
    
    // Determine alignment based on whether user is the payer
    final isPayer = transaction.transaction.payerId == me.id;
    
    return GestureDetector(
      onTap: () {
        // Mark as read on explicit open
        if (isUnread) {
          onOpened?.call();
        }
        // Navigate to full screen transaction detail
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              me: me,
              transactionId: transaction.id ?? 'unknown',
              userName: ledger.name,
              amount: affectedAmount,
              description: description,
              transactionDate: date,
              runningBalance: ledger.amount,
              splitDetails: transaction.transaction.splitDetails,
              totalAmount: transaction.transaction.totalAmount,
              payerId: transaction.transaction.payerId,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: size.height * 0.015,
          left: isPayer ? size.width * 0.2 : 0,
          right: isPayer ? 0 : size.width * 0.2,
        ),
        child: Row(
          mainAxisAlignment: isPayer ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isPayer) ...[
              Stack(
                children: [
                  CircleAvatar(
                    radius: size.width * 0.04,
                    backgroundImage: const AssetImage('assets/images/lion.jpg'),
                  ),
                  if (isUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: UnreadCountBadge(
                        count: 1,
                        size: 12,
                      ),
                    ),
                ],
              ),
              SizedBox(width: size.width * 0.02),
            ],
            Expanded(
              child: Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: isUnread ? kStockColor.withValues(alpha: 0.9) : kStockColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isUnread ? Border.all(color: kRedColor.withValues(alpha: 0.3), width: 1) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Affected Amount (Primary display)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₹ ${affectedAmount.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: amountColor,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'GT-Walsheim-Pro',
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kRedColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Total Amount (Secondary display)
                    SizedBox(height: size.height * 0.005),
                    Text(
                      'Total: ₹ ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: size.width * 0.03,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      description,
                      style: TextStyle(
                        color: kBlackColor,
                        fontSize: size.width * 0.035,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      '${date.day} ${_getMonthName(date.month)} ${date.year}, ${_formatTime(date)}',
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: size.width * 0.03,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isPayer) ...[
              SizedBox(width: size.width * 0.02),
              Stack(
                children: [
                  CircleAvatar(
                    radius: size.width * 0.04,
                    backgroundImage: const AssetImage('assets/images/lion.jpg'),
                  ),
                  if (isUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: UnreadCountBadge(
                        count: 1,
                        size: 12,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
} 