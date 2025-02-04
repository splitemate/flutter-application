import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';

class TransactionCard extends StatelessWidget {
  final String name;
  final String? time;
  final double amount;
  final String imageUrl;
  final bool isPositive;

  const TransactionCard({
    super.key,
    required this.name,
    required this.amount,
    required this.imageUrl,
    required this.isPositive,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final amountText = isPositive ? '+${amount.toStringAsFixed(2)}' : '-${amount.toStringAsFixed(2)}';
    final amountColor = isPositive ? Colors.green : Colors.red;
    final Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Card(
        elevation: 0,
        color: kWhiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.0333),
        ),
        margin: EdgeInsets.symmetric(vertical: size.width * 0.0139),
        child: Padding(
          padding: EdgeInsets.all(size.width *  0.0278),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: size.width * 0.0611,
                backgroundImage: NetworkImage(imageUrl),
              ),
              SizedBox(width: size.width * 0.0417),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.width *  0.0389,
                      ),
                    ),
                    SizedBox(height: size.width *  0.0139),
                    Text(
                      time!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: size.width * 0.0333,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amountText,
                style: TextStyle(
                  color: amountColor,
                  fontSize: size.width *  0.0389,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
