import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/states_management/bloc/transaction/transaction_bloc.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/states_management/home/transaction_thread_cubit.dart';
import 'package:splitemate/utils/transaction_calculator.dart';
import 'package:splitemate/widgets/common/new_message_indicator.dart';
import 'package:splitemate/widgets/common/unread_count_badge.dart';

class TransactionThread extends StatefulWidget {
  final List<User> receivers;
  final CurrentUser me;
  final Ledger ledger;
  final LedgerType ledgerType;
  final LedgersCubit ledgersCubit;

  const TransactionThread(
      {super.key,
      required this.receivers,
      required this.me,
      required this.ledger,
      required this.ledgerType,
      required this.ledgersCubit});

  @override
  State<TransactionThread> createState() => _TransactionThreadState();
}

class _TransactionThreadState extends State<TransactionThread> with WidgetsBindingObserver {
  String ledgerId = '';
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledUp = false;
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ledgerId = widget.ledger.id;
    _setupScrollListener();
    _updateOnMessageReceived();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh transactions when dependencies change (e.g., when navigating back)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionThreadCubit>().refreshTransactions();
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isScrolledUp = _scrollController.position.pixels < 
                          _scrollController.position.maxScrollExtent - 100;
      if (isScrolledUp != _isScrolledUp) {
        setState(() {
          _isScrolledUp = isScrolledUp;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh transactions when app becomes active
      context.read<TransactionThreadCubit>().refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.ledger.name,
                style: TextStyle(
                  color: kBlackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
            ),
            BlocBuilder<TransactionThreadCubit, TransactionThreadState>(
              builder: (context, state) {
                return UnreadCountBadge(
                  count: state.unreadCount,
                  size: 24,
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kBlackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kBlackColor),
            onPressed: () {
              context.read<TransactionThreadCubit>().refreshTransactions();
            },
          ),
        ],
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionReceivedSuccess) {
            print('TransactionThread: Received new transaction: ${state.transactionWrapper}');
            // Update the cubit with the new transaction
            context.read<TransactionThreadCubit>().handleNewTransaction(state.transactionWrapper);
          }
        },
        child: Column(
          children: [
            // Ledger Details Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: const AssetImage('assets/images/lion.jpg'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ledger.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GT-Walsheim-Pro',
                          ),
                        ),
                        SizedBox(height: 4),
                        BlocBuilder<TransactionThreadCubit, TransactionThreadState>(
                          builder: (context, state) {
                            return Text(
                              '${state.transactions.length} transactions • ${state.unreadCount} unread',
                              style: TextStyle(
                                fontSize: 14,
                                color: kGreyColor,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${widget.ledger.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.ledger.amount >= 0 ? kGreenColor : kRedColor,
                      fontFamily: 'GT-Walsheim-Pro',
                    ),
                  ),
                ],
              ),
            ),
            
            // Transactions List
            Expanded(
              child: BlocBuilder<TransactionThreadCubit, TransactionThreadState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${state.error}',
                            style: TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TransactionThreadCubit>().refreshTransactions();
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: kGreyColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              color: kGreyColor,
                              fontSize: 18,
                              fontFamily: 'GT-Walsheim-Pro',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Transactions with ${widget.ledger.name} will appear here',
                            style: TextStyle(
                              color: kGreyColor.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontFamily: 'GT-Walsheim-Pro',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Ensure we open at the bottom (latest transaction)
                  if (!_didInitialScroll) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _scrollController.hasClients) {
                        try {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                          _didInitialScroll = true;
                        } catch (e) {
                          // Fallback to animate if jump fails
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                          _didInitialScroll = true;
                        }
                      }
                    });
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: state.transactions.length,
                        itemBuilder: (context, index) {
                          final txn = state.transactions[index];
                          final isUnread = txn.receipt == ReceiptStatus.delivered;
                          
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
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
                            title: Text(
                              '₹${txn.transaction.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: TransactionCalculator.calculateAffectedAmount(
                                  transaction: txn.transaction,
                                  userId: widget.me.id,
                                ) >= 0 ? kGreenColor : kRedColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  txn.transaction.description,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${txn.transaction.transactionDate.day}/${txn.transaction.transactionDate.month}/${txn.transaction.transactionDate.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kGreyColor,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionDetailsPage(
                                    transaction: txn,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      
                      BlocBuilder<TransactionThreadCubit, TransactionThreadState>(
                        builder: (context, state) {
                          return NewMessageIndicator(
                            isVisible: state.hasNewMessages && _isScrolledUp,
                            messageCount: state.unreadCount,
                            onTap: () {
                              _scrollToBottom();
                              context.read<TransactionThreadCubit>().clearNewMessageIndicator();
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final bottom = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        bottom,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          final bottom = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(bottom);
        }
      });
    }
  }

  void _scrollToNewTransaction() {
    // For simple list view, just scroll to bottom where new transactions appear
    if (_scrollController.hasClients) {
      final bottom = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        bottom,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateOnMessageReceived() {
    final transactionThreadCubit = context.read<TransactionThreadCubit>();
    if (ledgerId.isNotEmpty) {
      // Set callback for new transaction - just log, don't auto-scroll
      transactionThreadCubit.setNewTransactionCallback((transactionId) {
        print('New transaction received in TransactionThread: $transactionId (no auto-scroll)');
        // Don't auto-scroll - let user manually click indicator to navigate
      });
      
      transactionThreadCubit.transactions(ledgerId, widget.ledgerType);
    }
  }
}

class TransactionDetailsPage extends StatelessWidget {
  final LocalTransaction transaction;

  const TransactionDetailsPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Summary
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction ID: ${transaction.id}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Amount: \$${transaction.transaction.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description: ${transaction.transaction.description}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Payer: ${transaction.transaction.payerId}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (transaction.transaction.groupId != null)
                          Text(
                            'Group: ${transaction.transaction.groupId}',
                            style: TextStyle(fontSize: 16),
                          ),
                        Text(
                          'Split Count: ${transaction.transaction.splitCount}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Transaction Type: ${transaction.transaction.transactionType}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Transaction Date: ${transaction.transaction.transactionDate}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Created By: ${transaction.transaction.createdBy}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Created At: ${transaction.transaction.createdAt}',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Updated At: ${transaction.transaction.updatedAt}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )),
              ),

              const SizedBox(height: 24),

              // Split Details
              Text(
                'Split Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transaction.transaction.splitDetails.length,
                itemBuilder: (context, index) {
                  final splitDetail =
                      transaction.transaction.splitDetails[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${splitDetail.name}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Email: ${splitDetail.email}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Amount: \$${splitDetail.amount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
