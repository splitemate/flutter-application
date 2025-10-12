import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/models/transaction.dart';
import 'package:splitemate/states_management/home/transaction_thread_cubit.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/viewmodels/ledger_view_model.dart';
import 'package:splitemate/widgets/transaction/transaction_detail_card.dart';
import 'package:splitemate/states_management/bloc/transaction/transaction_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TransactionListView extends StatefulWidget {
  final Ledger ledger;
  final CurrentUser me;
  final Size size;
  final LedgerType ledgerType;

  const TransactionListView({
    super.key,
    required this.ledger,
    required this.me,
    required this.size,
    required this.ledgerType,
  });

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final Set<String> _markedAsRead = <String>{};
  final Set<String> _newlyReceivedTransactions = <String>{}; // Track newly received transactions
  List<LocalTransaction> _flatTransactions = []; // Flattened list for index mapping
  List<dynamic> _displayItems = []; // Mix of transactions and date separators for display
  TransactionThreadCubit? _cubit;
  bool _hasInitiallyScrolled = false;
  bool _isUserScrolling = false; // Track if user is actively scrolling


  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _itemPositionsListener.itemPositions.addListener(() {
      if (!mounted) return;

      _isUserScrolling = true;

      Timer(const Duration(milliseconds: 500), () {
        _isUserScrolling = false;
      });
    });
  }

  @override
  void dispose() {
    _newlyReceivedTransactions.clear();
    _cubit = null;
    super.dispose();
  }
  void _jumpToLatestInstantly() {
    if (!mounted || _cubit == null) return;
    
    final transactions = _cubit!.state.transactions;
    if (transactions.isEmpty || _displayItems.isEmpty) return;
    
    // Find the index of the last transaction (not date separator) in display items
    int lastTransactionIndex = -1;
    for (int i = _displayItems.length - 1; i >= 0; i--) {
      if (_displayItems[i]['type'] == 'transaction') {
        lastTransactionIndex = i;
        break;
      }
    }
    
    if (lastTransactionIndex == -1) {
      print('No transactions found in display items');
      return;
    }
    
    print('Jumping instantly to latest transaction at display index $lastTransactionIndex of ${_displayItems.length}');
    
    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(index: lastTransactionIndex, alignment: 0.5);
      _hasInitiallyScrolled = true;
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _itemScrollController.isAttached) {
          _itemScrollController.jumpTo(index: lastTransactionIndex, alignment: 0.5);
          _hasInitiallyScrolled = true;
        }
      });
    }
  }


  void _scrollToTransaction(String transactionId, {double alignment = 0.9}) {
    print('_scrollToTransaction called for: $transactionId');
    
    if (!mounted) {
      print('Widget not mounted');
      return;
    }
    
    // Find the index of the transaction in the display items list
    int displayIndex = -1;
    for (int i = 0; i < _displayItems.length; i++) {
      final item = _displayItems[i];
      if (item['type'] == 'transaction') {
        final transaction = item['transaction'] as LocalTransaction;
        if (transaction.id == transactionId) {
          displayIndex = i;
          break;
        }
      }
    }
    
    // Fallback: search in the flattened transaction list
    if (displayIndex == -1) {
      int flatIndex = _flatTransactions.indexWhere((t) => t.id == transactionId);
      if (flatIndex != -1) {
        // Convert flat index to display index (approximation)
        // This is less accurate but better than nothing
        displayIndex = flatIndex;
        print('Using fallback flat index: $flatIndex -> display index: $displayIndex');
      }
    }
    
    if (displayIndex == -1) {
      print('Transaction not found in display items: $transactionId');
      return;
    }
    
    print('Found transaction at display index $displayIndex, scrolling...');
    _scrollToIndex(displayIndex, alignment: alignment);
  }
  
  void _scrollToIndex(int index, {double alignment = 0.9}) {
    if (!mounted) return;
    
    // Check if the ScrollablePositionedList is ready
    if (!_itemScrollController.isAttached) {
      print('ItemScrollController not attached yet, delaying scroll...');
      // Wait for the list to be built and attached
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _itemScrollController.isAttached) {
          _scrollToIndexNow(index, alignment: alignment);
        }
      });
      return;
    }
    
    _scrollToIndexNow(index, alignment: alignment);
  }
  
  void _scrollToIndexNow(int index, {double alignment = 0.9}) {
    if (!mounted || !_itemScrollController.isAttached) return;
    
    try {
      print('Scrolling to index $index');
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: alignment, // custom alignment
      );
    } catch (e) {
      print('Error scrolling to index $index: $e');
      // If scroll fails, retry after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _itemScrollController.isAttached) {
          try {
            _itemScrollController.scrollTo(
              index: index,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              alignment: alignment,
            );
          } catch (retryError) {
            print('Retry scroll also failed: $retryError');
          }
        }
      });
    }
  }
  
  // Create flattened list from transactions for scroll indexing (ascending: oldest -> newest)
  void _buildFlatTransactionList(List<LocalTransaction> transactions) {
    // The cubit already ensures ascending order; just copy
    _flatTransactions = List<LocalTransaction>.from(transactions);
    
    // Build display items list with date separators
    _buildDisplayItemsWithDateSeparators(transactions);
    
    print('Built flat transaction list with ${_flatTransactions.length} items and ${_displayItems.length} display items');
  }
  
  void _buildDisplayItemsWithDateSeparators(List<LocalTransaction> transactions) {
    _displayItems.clear();
    
    if (transactions.isEmpty) return;
    
    // Group transactions by date
    final grouped = _groupTransactionsByDate(transactions);
    
    // Build display items alternating between date separators and transactions
    for (final group in grouped) {
      final dateText = group['dateText'] as String;
      final groupTransactions = group['transactions'] as List<LocalTransaction>;
      
      // Add date separator
      _displayItems.add({
        'type': 'date_separator',
        'dateText': dateText,
      });
      
      // Add all transactions for this date
      _displayItems.addAll(groupTransactions.map((t) => {
        'type': 'transaction',
        'transaction': t,
      }));
    }
  }

  void _scrollToNewestUnreadTransaction() {
    if (_cubit == null) return;
    
    final unreadTransactions = _cubit!.state.transactions
        .where((t) => t.receipt == ReceiptStatus.delivered)
        .toList();
        
    if (unreadTransactions.isEmpty) {
      // If no unread, scroll to latest transaction (not date separator)
      if (_displayItems.isNotEmpty) {
        int lastTransactionIndex = -1;
        for (int i = _displayItems.length - 1; i >= 0; i--) {
          if (_displayItems[i]['type'] == 'transaction') {
            lastTransactionIndex = i;
            break;
          }
        }
        if (lastTransactionIndex != -1) {
          _scrollToIndex(lastTransactionIndex, alignment: 0.8);
        }
      }
      return;
    }
    
    // Find the most recent unread transaction
    final newestUnread = unreadTransactions.reduce((a, b) => 
      a.transaction.transactionDate.isAfter(b.transaction.transactionDate) ? a : b
    );
    
    print('Scrolling to newest unread transaction: ${newestUnread.id}');
    // Place the target unread message slightly above center so older are above and latest is visible below
    _scrollToTransaction(newestUnread.id!, alignment: 0.4);
  }
  
  
  Widget _buildUnreadIndicator(int unreadCount, int totalTransactions) {
    // Show banner only when there are enough messages to warrant an indicator
    if (unreadCount <= 0 || totalTransactions < 4) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            print('Indicator tapped - scrolling to unread transaction');
            _scrollToNewestUnreadTransaction();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.size.width * 0.04,
              vertical: widget.size.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: kRedColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$unreadCount New Transaction${unreadCount > 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.size.width * 0.032,
                fontWeight: FontWeight.w600,
                fontFamily: 'GT-Walsheim-Pro',
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _onTransactionVisible(String transactionId) {
    if (_cubit == null || !mounted) return;
    
    final transaction = _cubit!.state.transactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => LocalTransaction(ledgerId: '', transaction: Transaction(
        payerId: '', totalAmount: 0, splitCount: 0, description: '',
        transactionType: TransactionType.debt, transactionDate: DateTime.now(),
        createdAt: DateTime.now(), createdBy: '', updatedAt: DateTime.now(),
        ledgerType: LedgerType.individual, splitDetails: [], groupId: '',
      ), receipt: ReceiptStatus.read),
    );
    
    // Only process unread transactions that haven't been marked yet
    if (transaction.receipt != ReceiptStatus.delivered || 
        _markedAsRead.contains(transactionId)) {
      return;
    }
    
    // Immediately mark as read once sufficiently visible/opened
    print('Marking transaction as read immediately: $transactionId');
    _markTransactionAsRead(transactionId);
    _newlyReceivedTransactions.remove(transactionId);
  }
  
  void _markTransactionAsRead(String transactionId) {
    if (_cubit == null || _markedAsRead.contains(transactionId)) return;
    
    _markedAsRead.add(transactionId);
    _cubit!.markTransactionsAsReadByIds([transactionId]);
    
  }
  
  void _onTransactionHidden(String transactionId) {
    // No-op: immediate read logic, nothing to cancel
  }
  
  bool _hasReadStatusChanged(List<LocalTransaction> previous, List<LocalTransaction> current) {
    if (previous.length != current.length) return false; // Length changes handled separately
    
    for (int i = 0; i < previous.length; i++) {
      if (previous[i].receipt != current[i].receipt) {
        return true; // Found a read status change
      }
    }
    return false; // No read status changes
  }
  
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = TransactionThreadCubit(
          LedgerViewModel(context.read<LedgersCubit>().viewModel.datasource),
        );
        
        // Store cubit reference
        _cubit = cubit;
        
        // Set callback to update ledger unread counts
        cubit.setUnreadCountChangedCallback((ledgerId, ledgerType) {
          context.read<LedgersCubit>().updateLedgerUnreadCount(ledgerId, ledgerType);
        });
        
        // Set callback for new transaction - just log, don't auto-scroll
        cubit.setNewTransactionCallback((transactionId) {
          print('New transaction received: $transactionId (no auto-scroll)');
          // Don't auto-scroll - let user manually click indicator to navigate
        });
        
        // Load transactions
        cubit.transactions(widget.ledger.id, widget.ledgerType);
        
        return cubit;
      },
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionReceivedSuccess) {
            final transactionId = state.transactionWrapper.id;
            print('New transaction received: $transactionId');
            
            if (transactionId != null) {
              // Mark as newly received for 15 seconds (longer than read delay)
              _newlyReceivedTransactions.add(transactionId);
              
              Timer(const Duration(seconds: 15), () {
                _newlyReceivedTransactions.remove(transactionId);
                print('Removed transaction from newly received: $transactionId');
              });
            }
            
            // Update cubit with new transaction
            context.read<TransactionThreadCubit>().handleNewTransaction(state.transactionWrapper);
          }
        },
        child: BlocListener<TransactionThreadCubit, TransactionThreadState>(
          listenWhen: (previous, current) {
            // Listen for initial load and new transactions, but NOT read status changes
            return previous.transactions.length != current.transactions.length;
          },
          listener: (context, state) {
            // No need for manual unread count updates - using real-time state
          },
          child: BlocBuilder<TransactionThreadCubit, TransactionThreadState>(
            buildWhen: (previous, current) {
              // Rebuild for structure changes AND read status changes (to update NEW labels)
              return previous.transactions.length != current.transactions.length ||
                     previous.isLoading != current.isLoading ||
                     previous.error != current.error ||
                     _hasReadStatusChanged(previous.transactions, current.transactions);
            },
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
              return _buildEmptyState();
            }

            // Build flattened transaction list for scrolling
            _buildFlatTransactionList(state.transactions);
            
            // Compute unread count directly from state to keep indicator accurate
            final unreadCount = state.transactions
                .where((t) => t.receipt == ReceiptStatus.delivered)
                .length;
            final totalTransactions = state.transactions.length;
            
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<TransactionThreadCubit>().refreshTransactions();
                  },
                  child: Builder(
                    builder: (context) {
                      // Determine the display index of the last transaction (ignore date separators)
                      int initialIndex = 0;
                      if (_displayItems.isNotEmpty) {
                        for (int i = _displayItems.length - 1; i >= 0; i--) {
                          final item = _displayItems[i];
                          if (item is Map && item['type'] == 'transaction') {
                            initialIndex = i;
                            break;
                          }
                        }
                      }
                      
                      return ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        itemPositionsListener: _itemPositionsListener,
                        padding: EdgeInsets.all(widget.size.width * 0.04),
                        initialScrollIndex: initialIndex,
                        initialAlignment: 0.5,
                        itemCount: _displayItems.length,
                        itemBuilder: (context, index) {
                          final item = _displayItems[index];
                          
                          if (item['type'] == 'date_separator') {
                            return _buildDateSeparator(item['dateText'] as String);
                          } else if (item['type'] == 'transaction') {
                        final transaction = item['transaction'] as LocalTransaction;
                        final transactionId = transaction.id!;
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                              child: VisibilityDetector(
                                key: Key('visibility_$transactionId'),
                            onVisibilityChanged: (visibilityInfo) {
                              // Do not mark as read on visibility anymore; only on tap
                            },
                                child: TransactionDetailCard(
                                  transaction: transaction,
                                  ledger: widget.ledger,
                                  me: widget.me,
                                  size: widget.size,
                                  onOpened: () {
                                    _markTransactionAsRead(transactionId);
                                  },
                                ),
                              ),
                            );
                          }
                          
                          return const SizedBox.shrink(); // Fallback for unknown item types
                        },
                      );
                    },
                  ),
                ),
                
                // Unread Transactions Indicator (only when 4+ transactions)
                _buildUnreadIndicator(unreadCount, totalTransactions),
              ],
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.size.width * 0.04),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: widget.size.width * 0.15,
              color: kGreyColor,
            ),
            SizedBox(height: widget.size.height * 0.02),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: kGreyColor,
                fontSize: widget.size.width * 0.04,
                fontFamily: 'GT-Walsheim-Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: widget.size.height * 0.01),
            Text(
              'Transactions with ${widget.ledger.name} will appear here',
              style: TextStyle(
                color: kGreyColor.withValues(alpha: 0.7),
                fontSize: widget.size.width * 0.035,
                fontFamily: 'GT-Walsheim-Pro',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(String dateText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.size.height * 0.015),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.size.width * 0.04,
            vertical: widget.size.height * 0.008,
          ),
          decoration: BoxDecoration(
            color: kStockColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kGreyColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              color: kGreyColor.withValues(alpha: 0.8),
              fontSize: widget.size.width * 0.032,
              fontFamily: 'GT-Walsheim-Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupTransactionsByDate(List<LocalTransaction> transactions) {
    final grouped = <Map<String, dynamic>>[];
    final dateGroups = <String, List<LocalTransaction>>{};

    // Create a map to store actual dates for proper sorting
    final dateToDateTime = <String, DateTime>{};

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
        dateToDateTime[dateText] = DateTime(date.year, date.month, date.day);
      }
      dateGroups[dateText]!.add(transaction);
    }

    // Sort transactions within each date group by transaction date (oldest first)
    dateGroups.forEach((dateText, transactionList) {
      transactionList.sort((a, b) => a.transaction.transactionDate.compareTo(b.transaction.transactionDate));
      
      grouped.add({
        'dateText': dateText,
        'transactions': transactionList,
        'date': dateToDateTime[dateText],
      });
    });

    // Sort groups by date (oldest dates first - will be reversed in UI)
    grouped.sort((a, b) {
      final aText = a['dateText'] as String;
      final bText = b['dateText'] as String;
      final aDate = a['date'] as DateTime;
      final bDate = b['date'] as DateTime;
      
      // Handle special date texts
      if (aText == 'Today' && bText != 'Today') return 1;
      if (bText == 'Today' && aText != 'Today') return -1;
      if (aText == 'Yesterday' && bText != 'Yesterday' && bText != 'Today') return 1;
      if (bText == 'Yesterday' && aText != 'Yesterday' && aText != 'Today') return -1;
      
      // For all other cases, sort by actual date
      return aDate.compareTo(bDate);
    });

    return grouped;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
