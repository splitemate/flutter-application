import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/ledger.dart';

class ChatViewHeader extends StatelessWidget {
  final Ledger ledger;
  final Size size;
  final VoidCallback onBackPressed;
  final String subtitle;
  final Widget? trailingWidget;

  const ChatViewHeader({
    super.key,
    required this.ledger,
    required this.size,
    required this.onBackPressed,
    required this.subtitle,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + size.height * 0.02,
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
          // Header Row
          Row(
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: kWhiteColor),
                onPressed: onBackPressed,
              ),
              // Profile Image
              CircleAvatar(
                radius: size.width * 0.06,
                backgroundImage: const AssetImage('assets/images/lion.jpg'),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ledger.name,
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: kWhiteColor.withValues(alpha: 0.8),
                        fontSize: size.width * 0.035,
                        fontFamily: 'GT-Walsheim-Pro',
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing Widget (Call button, More options, etc.)
              if (trailingWidget != null) trailingWidget!,
            ],
          ),
          SizedBox(height: size.height * 0.02),
          // Balance Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ledger.type == LedgerType.individual ? 'Balance' : 'Group Balance',
                  style: TextStyle(
                    color: kBlackColor,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GT-Walsheim-Pro',
                  ),
                ),
                Text(
                  '₹ ${ledger.amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: ledger.amount > 0 ? kRedColor : kGreenColor,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GT-Walsheim-Pro',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 