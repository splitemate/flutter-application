import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/widgets/cards/amount_summary.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(
              width: 7,
            ),
            Text(
              'Splitemate',
              style: TextStyle(
                  color: kBlackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.0667,
                  fontFamily: 'Lexend'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined, color: kBlackColor),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_active, color: kBlackColor),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size.width * 0.033),
                bottomRight: Radius.circular(size.width * 0.033),
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(size.width * 0.033),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.0333),
                          gradient: const LinearGradient(
                            colors: kGradColors,
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.2778,
                          vertical: size.width * 0.0417,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Total balance',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: 'GT-Walsheim-Pro'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹ ${userProvider.user.netBalance % 1 == 0 ? userProvider.user.netBalance.toInt() : userProvider.user.netBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.0889,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -40,
                        top: -35,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        right: -40,
                        top: -35,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: 5,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AmountSummary(
                          title: 'I Owed',
                          amount: userProvider.user.totalOwed.abs() % 1 == 0
                              ? userProvider.user.totalOwed
                                  .abs()
                                  .toInt()
                                  .toString()
                              : userProvider.user.totalOwed
                                  .abs()
                                  .toStringAsFixed(2),
                          amountColor: Colors.green,
                          assetPath: 'assets/images/income.svg'),
                      SizedBox(width: size.width * 0.0333),
                      AmountSummary(
                          title: 'I paid',
                          amount: userProvider.user.totalDue.abs() % 1 == 0
                              ? userProvider.user.totalDue
                                  .abs()
                                  .toInt()
                                  .toString()
                              : userProvider.user.totalDue
                                  .abs()
                                  .toStringAsFixed(2),
                          amountColor: Colors.red,
                          assetPath: 'assets/images/expense.svg')
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
              ],
            ),
          ),
          Container(
            child: Text('HI'),
          )
        ],
      ),
    );
  }
}
