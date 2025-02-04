import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';


class AmountSummary extends StatelessWidget {
  final String title;
  final String amount;
  final Color amountColor;
  final String assetPath;

  const AmountSummary({
    super.key,
    required this.title,
    required this.amount,
    required this.amountColor,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(size.width * 0.0333),
        decoration: BoxDecoration(
          border: Border.all(color: kStockColor, width: 1.5),
          color: Colors.white,
          borderRadius: BorderRadius.circular(size.width * 0.0333),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.0278),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto'
                    ),
                  ),
                  SizedBox(height: size.width * 0.0139),
                  Text(
                    amount,
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'
                    ),
                  ),
                ],
              ),
              SvgPicture.asset(assetPath),
            ],
          ),
        ),
      ),
    );
  }
}
