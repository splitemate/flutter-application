import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/transaction.dart';

class TransactionDetailScreen extends StatefulWidget {
  final CurrentUser me;
  final String transactionId;
  final String userName;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final double runningBalance;
  final List<SplitDetail>? splitDetails;
  final double totalAmount;
  final String payerId;

  const TransactionDetailScreen({
    super.key,
    required this.me,
    required this.transactionId,
    required this.userName,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.runningBalance,
    this.splitDetails,
    required this.totalAmount,
    required this.payerId,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: size.height * 0.02,
                  left: size.width * 0.04,
                  right: size.width * 0.04,
                  bottom: size.height * 0.02,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: kGradColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: kWhiteColor),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Transaction Details',
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'GT-Walsheim-Pro',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: size.width * 0.12),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),

              // Main Content Card
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(size.width * 0.06),
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.06),
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: kBlackColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            color: kGreyColor,
                            fontSize: size.width * 0.035,
                            fontFamily: 'GT-Walsheim-Pro',
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          widget.description,
                          style: TextStyle(
                            color: kBlackColor,
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GT-Walsheim-Pro',
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Transaction Amount',
                              style: TextStyle(
                                color: kGreyColor,
                                fontSize: size.width * 0.035,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                            Text(
                              '₹ ${widget.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.02),

                        // Affected Amount Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Affected Amount',
                              style: TextStyle(
                                color: kGreyColor,
                                fontSize: size.width * 0.035,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                            Text(
                              '₹ ${widget.amount.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color:
                                    widget.amount > 0 ? kGreenColor : kRedColor,
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                          ],
                        ),

                        // Date and Time Section
                        SizedBox(height: size.height * 0.02),
                        Container(
                          padding: EdgeInsets.all(size.width * 0.04),
                          decoration: BoxDecoration(
                            color: kStockColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: kGradColors[0],
                                size: size.width * 0.05,
                              ),
                              SizedBox(width: size.width * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date: ${widget.transactionDate.day} ${_getMonthName(widget.transactionDate.month)} ${widget.transactionDate.year}',
                                      style: TextStyle(
                                        color: kBlackColor,
                                        fontSize: size.width * 0.035,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'GT-Walsheim-Pro',
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    Text(
                                      'Time: ${_formatTime(widget.transactionDate)}',
                                      style: TextStyle(
                                        color: kGreyColor,
                                        fontSize: size.width * 0.03,
                                        fontFamily: 'GT-Walsheim-Pro',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Split Details Section (if available)
                        if (widget.splitDetails != null &&
                            widget.splitDetails!.isNotEmpty) ...[
                          SizedBox(height: size.height * 0.04),

                          Text(
                            'Split Details',
                            style: TextStyle(
                              color: kGreyColor,
                              fontSize: size.width * 0.035,
                              fontFamily: 'GT-Walsheim-Pro',
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),

                          // Payer Identification Section
                          Container(
                            padding: EdgeInsets.all(size.width * 0.04),
                            decoration: BoxDecoration(
                              color: kStockColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: size.width * 0.04,
                                  backgroundImage: const AssetImage(
                                      'assets/images/lion.jpg'),
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: Text(
                                    widget.payerId == widget.me.id
                                        ? 'You paid ₹ ${widget.totalAmount.toStringAsFixed(2)}'
                                        : '${_getPayerName(widget.payerId)} paid ₹ ${widget.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: kBlackColor,
                                      fontSize: size.width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'GT-Walsheim-Pro',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          // Split Details List
                          Container(
                            decoration: BoxDecoration(
                              color: kStockColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: widget.splitDetails!
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final splitDetail = entry.value;
                                final isCurrentUser =
                                    splitDetail.id == widget.me.id;
                                final isLastItem =
                                    index == widget.splitDetails!.length - 1;

                                return Container(
                                  padding: EdgeInsets.all(size.width * 0.04),
                                  decoration: BoxDecoration(
                                    border: isLastItem
                                        ? null
                                        : Border(
                                            bottom: BorderSide(
                                              color: kGreyColor.withValues(
                                                  alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                  ),
                                  child: Row(
                                    children: [
                                      // User Avatar
                                      CircleAvatar(
                                        radius: size.width * 0.04,
                                        backgroundImage: const AssetImage(
                                            'assets/images/lion.jpg'),
                                      ),
                                      SizedBox(width: size.width * 0.03),

                                      // User Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              splitDetail.name,
                                              style: TextStyle(
                                                color: kBlackColor,
                                                fontSize: size.width * 0.04,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'GT-Walsheim-Pro',
                                              ),
                                            ),
                                            if (isCurrentUser) ...[
                                              SizedBox(
                                                  height: size.height * 0.005),
                                              Text(
                                                'You owe ₹ ${splitDetail.amount.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: kGradColors[0],
                                                  fontSize: size.width * 0.035,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'GT-Walsheim-Pro',
                                                ),
                                              ),
                                            ] else ...[
                                              SizedBox(
                                                  height: size.height * 0.005),
                                              Text(
                                                '${splitDetail.name} owes ₹ ${splitDetail.amount.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: kGreyColor,
                                                  fontSize: size.width * 0.035,
                                                  fontFamily: 'GT-Walsheim-Pro',
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Amount
                                      Text(
                                        '₹ ${splitDetail.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? kGradColors[0]
                                              : kBlackColor,
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'GT-Walsheim-Pro',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        SizedBox(height: size.height * 0.04),

                        // Edit Entry Button
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              // TODO: Implement edit functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Edit functionality coming soon!'),
                                  backgroundColor: kGreenColor,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.edit,
                              color: kGradColors[0],
                              size: size.width * 0.05,
                            ),
                            label: Text(
                              'EDIT ENTRY',
                              style: TextStyle(
                                color: kGradColors[0],
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GT-Walsheim-Pro',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Delete Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.06),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.06,
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kRedColor, width: 2),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: kRedColor,
                      size: size.width * 0.05,
                    ),
                    label: Text(
                      'DELETE',
                      style: TextStyle(
                        color: kRedColor,
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPayerName(String payerId) {
    // Find the payer's name from split details
    if (widget.splitDetails != null) {
      final payerDetail = widget.splitDetails!.firstWhere(
        (detail) => detail.id == payerId,
        orElse: () => widget.splitDetails!.first,
      );
      return payerDetail.name;
    }
    return 'Unknown Payer';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Transaction',
            style: TextStyle(
              fontFamily: 'GT-Walsheim-Pro',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'GT-Walsheim-Pro',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: kGreyColor,
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete functionality
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: kRedColor,
                  fontFamily: 'GT-Walsheim-Pro',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
