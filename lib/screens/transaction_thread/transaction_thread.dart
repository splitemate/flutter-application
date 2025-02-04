import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/states_management/home/transaction_thread_cubit.dart';

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

class _TransactionThreadState extends State<TransactionThread> {
  List<LocalTransaction> transaction = [];
  String ledgerId = '';

  @override
  void initState() {
    super.initState();

    ledgerId = widget.ledger.id;
    _updateOnMessageReceived();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ledger.name),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ledger Details Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ledger Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Ledger ID: ${widget.ledger.id}'),
                Text('Type: ${widget.ledger.type}'),
                Text('Unread: ${widget.ledger.unread}'),
                Text('Amount: \$${widget.ledger.amount.toStringAsFixed(2)}'),
                if (widget.ledger.members != null)
                  Text('Members: ${widget.ledger.members}'),
                Text('Total Members: ${widget.ledger.membersId.length}'),
                if (widget.ledger.mostRecent != null)
                  Text(
                      'Most Recent Transaction: ${widget.ledger.mostRecent!.id}'),
                if (widget.ledger.imageUrl != null)
                  Text('Image URL: ${widget.ledger.imageUrl}'),
                if (widget.ledger.createdAt != null)
                  Text(
                    'Created At: ${widget.ledger.createdAt}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                if (widget.ledger.updatedAt != null)
                  Text(
                    'Updated At: ${widget.ledger.updatedAt}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.grey),

          // Transaction List Section
          Expanded(
            child: BlocBuilder<TransactionThreadCubit, List<LocalTransaction>>(
              builder: (context, transaction) {
                if (transaction.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: transaction.length,
                  itemBuilder: (context, index) {
                    final txn = transaction[index];

                    // Ensure txn.id is not null and has at least 2 characters
                    String displayId = (txn.id != null && txn.id!.length >= 2)
                        ? txn.id!.substring(0, 2).toUpperCase()
                        : txn.id!.isNotEmpty
                            ? txn.id!
                                .toUpperCase() // If id is 1 character, use it
                            : "??"; // Default placeholder if empty

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            displayId, // ✅ Fixed potential substring error
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          'Transaction ID: ${txn.id ?? "Unknown"}',
                          // Handle null ID safely
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount: \$${txn.transaction.totalAmount}'),
                            Text(
                              'Description: ${txn.transaction.description}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('Date: ${txn.transaction.transactionDate}'),
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateOnMessageReceived() {
    final transactionThreadCubit = context.read<TransactionThreadCubit>();
    if (ledgerId.isNotEmpty) transactionThreadCubit.transactions(ledgerId, widget.ledgerType);
    // _subscription = widget.messageBloc.stream.listen((state) async {
    //   if (state is MessageReceivedSuccess) {
    //     await messageThreadCubit.viewModel.receivedMessage(state.message);
    //     final receipt = Receipt(
    //       recipient: state.message.from,
    //       messageId: state.message.id,
    //       status: ReceiptStatus.read,
    //       timestamp: DateTime.now(),
    //     );
    //     context.read<ReceiptBloc>().add(ReceiptEvent.onMessageSent(receipt));
    //   }
    //   if (state is MessageSentSuccess) {
    //     await messageThreadCubit.viewModel.sentMessage(state.message);
    //     widget.chatsCubit.chats();
    //   }
    //   if (chatId.isEmpty) chatId = messageThreadCubit.viewModel.chatId;
    //   messageThreadCubit.messages(chatId);
    // });
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
