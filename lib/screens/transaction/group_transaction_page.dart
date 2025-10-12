import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/screens/transaction/transaction_detail_screen.dart';
import 'package:splitemate/states_management/bloc/transaction/transaction_bloc.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/utils/transaction_calculator.dart';
import 'package:splitemate/utils/time.dart';
import 'package:splitemate/widgets/common/empty_transactions.dart';
import 'package:splitemate/widgets/transaction/chat_view_header.dart';
import 'package:splitemate/widgets/transaction/action_buttons.dart';
import 'package:splitemate/widgets/common/unread_count_badge.dart';
import 'package:splitemate/widgets/transaction/transaction_list_view.dart';
import 'package:splitemate/screens/home/home_router.dart';

class GroupTransactionPage extends StatefulWidget {
  final CurrentUser me;
  final IHomeRouter router;

  const GroupTransactionPage(
      {super.key, required this.me, required this.router});

  @override
  State<GroupTransactionPage> createState() => _GroupTransactionPageState();
}

class _GroupTransactionPageState extends State<GroupTransactionPage> {
  var ledgers = [];
  Ledger? selectedLedger;
  bool showChatView = false;

  @override
  void initState() {
    context.read<LedgersCubit>().ledgers(LedgerType.group);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<LedgersCubit, List<Ledger>>(builder: (__, ledgers) {
      this.ledgers = ledgers;
      if (this.ledgers.isEmpty) {
        return const EmptyTransactions(
          isPersonal: false,
        );
      }

      return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, transactionState) {
          if (transactionState is TransactionReceivedSuccess) {
            print(
                "New transaction received: ${transactionState.transactionWrapper}");
          }
          
          if (showChatView && selectedLedger != null) {
            return _buildChatView(size);
          }
          
          return _buildLedgerListView(size);
        },
      );
    });
  }

  Widget _buildLedgerListView(Size size) {
    // Filter out ledgers where the current user is the creator
    final filteredLedgers = ledgers.where((ledger) {
      // For group transactions, exclude ledgers where the current user is the creator
      // This prevents showing our own name in the ledger list
      return ledger.members.any((member) => member.id == widget.me.id) && 
             ledger.members.any((member) => member.id != widget.me.id);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(top: size.width * 0.044),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredLedgers.length,
        itemBuilder: (context, index) {
          final item = filteredLedgers[index];
          return _buildLedgerItem(size, item);
        },
      ),
    );
  }

  Widget _buildLedgerItem(Size size, Ledger item) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to full-screen chat view instead of showing inline
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => _GroupChatViewScreen(
                  me: widget.me,
                  ledger: item,
                  size: size,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Row(
              children: [
                // Group Profile Image with Unread Badge
                Stack(
                  children: [
                    CircleAvatar(
                      radius: size.width * 0.06,
                      backgroundImage: const AssetImage('assets/images/lion.jpg'),
                    ),
                    if (item.unread > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: UnreadCountBadge(
                          count: item.unread,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: size.width * 0.04),
                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: kBlackColor,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GT-Walsheim-Pro',
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      Text(
                        getTimeInLocalZone(item.updatedAt ?? DateTime.now()),
                        style: TextStyle(
                          color: kGreyColor,
                          fontSize: size.width * 0.035,
                          fontFamily: 'GT-Walsheim-Pro',
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  '₹ ${item.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item.amount > 0 ? kRedColor : kGreenColor,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GT-Walsheim-Pro',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView(Size size) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            // Custom Header using reusable component
            ChatViewHeader(
              ledger: selectedLedger!,
              size: size,
              onBackPressed: () {
                setState(() {
                  showChatView = false;
                  selectedLedger = null;
                });
              },
              subtitle: 'Group Settings',
              trailingWidget: IconButton(
                icon: const Icon(Icons.more_vert, color: kWhiteColor),
                onPressed: () {
                  // TODO: Implement group options
                },
              ),
            ),
            
            // Transaction List using reusable component
            Expanded(
              child: TransactionListView(
                ledger: selectedLedger!,
                me: widget.me,
                size: size,
                ledgerType: LedgerType.group,
              ),
            ),
            
            // Bottom Action Buttons using reusable component
            ActionButtons(
              size: size,
              leftButtonText: 'ADD EXPENSE',
              rightButtonText: 'SETTLE UP',
              onLeftButtonPressed: () {
                // TODO: Implement group expense functionality
              },
              onRightButtonPressed: () {
                // TODO: Navigate to add group transaction screen
              },
            ),
          ],
        ),
      ),
    );
  }



  List<Map<String, dynamic>> _groupTransactionsByDate(List<LocalTransaction> transactions) {
    final grouped = <Map<String, dynamic>>[];
    final dateGroups = <String, List<LocalTransaction>>{};

    for (final transaction in transactions) {
      final date = transaction.transaction.transactionDate;
      final daysDiff = DateTime.now().difference(date).inDays;
      
      String dateText;
      if (daysDiff == 0) {
        dateText = 'Today';
      } else if (daysDiff == 1) {
        dateText = 'Yesterday';
      } else {
        dateText = '${date.day} ${_getMonthName(date.month)} ${date.year}';
      }

      if (!dateGroups.containsKey(dateText)) {
        dateGroups[dateText] = [];
      }
      dateGroups[dateText]!.add(transaction);
    }

    dateGroups.forEach((dateText, transactionList) {
      grouped.add({
        'dateText': dateText,
        'transactions': transactionList,
      });
    });

    // Sort by date (Today first, then Yesterday, then specific dates)
    grouped.sort((a, b) {
      final aText = a['dateText'] as String;
      final bText = b['dateText'] as String;
      
      if (aText == 'Today') return -1;
      if (bText == 'Today') return 1;
      if (aText == 'Yesterday') return -1;
      if (bText == 'Yesterday') return 1;
      
      return 0; // Keep specific dates in their original order
    });

    return grouped;
  }

  Widget _buildTransactionBubble(Size size, LocalTransaction transaction) {
    final totalAmount = transaction.transaction.totalAmount;
    final description = transaction.transaction.description;
    final date = transaction.transaction.transactionDate;
    final isUnread = transaction.receipt == ReceiptStatus.delivered;
    
    // Calculate affected amount using the new calculator
    final affectedAmount = TransactionCalculator.calculateAffectedAmount(
      transaction: transaction.transaction,
      userId: widget.me.id,
    );
    
    // Determine color and alignment based on affected amount
    final amountColor = affectedAmount >= 0 ? kGreenColor : kRedColor;
    final isPayer = transaction.transaction.payerId == widget.me.id;
    
    // Create display message
    String displayMessage = '';
    if (affectedAmount >= 0) {
      displayMessage = '₹${affectedAmount.abs().toStringAsFixed(2)} will be received';
    } else {
      displayMessage = '₹${affectedAmount.abs().toStringAsFixed(2)} will be paid';
    }
    
    return GestureDetector(
      onTap: () {
        // Navigate to full screen transaction detail
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              me: widget.me,
              transactionId: transaction.id ?? 'unknown',
              userName: selectedLedger!.name,
              amount: affectedAmount,
              description: description,
              transactionDate: date,
              runningBalance: selectedLedger!.amount,
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
              CircleAvatar(
                radius: size.width * 0.04,
                backgroundImage: const AssetImage('assets/images/lion.jpg'),
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
                    // Affected Amount
                    Text(
                      '₹ ${affectedAmount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: amountColor,
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    // Total Amount
                    Text(
                      'Total: ₹ ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: size.width * 0.03,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    // Display Message
                    Text(
                      displayMessage,
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
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: kRedColor,
                          shape: BoxShape.circle,
                        ),
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

  @override
  void dispose() {
    super.dispose();
  }
}

// Full-screen group chat view screen
class _GroupChatViewScreen extends StatelessWidget {
  final CurrentUser me;
  final Ledger ledger;
  final Size size;

  const _GroupChatViewScreen({
    required this.me,
    required this.ledger,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            // Custom Header using reusable component
            ChatViewHeader(
              ledger: ledger,
              size: size,
              onBackPressed: () => Navigator.of(context).pop(),
              subtitle: 'Group Settings',
              trailingWidget: IconButton(
                icon: const Icon(Icons.more_vert, color: kWhiteColor),
                onPressed: () {
                  // TODO: Implement group options
                },
              ),
            ),
            
            // Transaction List using reusable component
            Expanded(
              child: TransactionListView(
                ledger: ledger,
                me: me,
                size: size,
                ledgerType: LedgerType.group,
              ),
            ),
            
            // Bottom Action Buttons using reusable component
            ActionButtons(
              size: size,
              leftButtonText: 'ADD EXPENSE',
              rightButtonText: 'SETTLE UP',
              onLeftButtonPressed: () {
                // TODO: Implement group expense functionality
              },
              onRightButtonPressed: () {
                // TODO: Navigate to add group transaction screen
              },
            ),
          ],
        ),
      ),
    );
  }


}
