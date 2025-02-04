import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';
import 'package:splitemate/widgets/common/simple_button.dart';
import 'package:splitemate/widgets/common/list.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    List<Map<String, String>> preferenceList = [
      {'name': 'Email Setting', 'iconPath': 'assets/images/email.svg'},
      {
        'name': 'Device And Push Notification',
        'iconPath': 'assets/images/notification.svg'
      },
      {'name': 'Passcode', 'iconPath': 'assets/images/passcode.svg'}
    ];

    List<Map<String, String>> feedbackList = [
      {'name': 'Rate Splitemate', 'iconPath': 'assets/images/rate.svg'},
      {'name': 'Contact Support', 'iconPath': 'assets/images/support.svg'}
    ];

    return Container(
      color: kWhiteColor,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(
                  height: size.width * 0.1,
                ),
                SizedBox(
                  width: size.width * 0.35,
                  height: size.width * 0.35,
                  child: FractionallySizedBox(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: kGradColors,
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: const FractionallySizedBox(
                        widthFactor: 0.92,
                        heightFactor: 0.92,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/lion.jpg'),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.02),
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: size.width * 0.05,
                  ),
                ),
                SizedBox(height: size.width * 0.02),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.08),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: SimpleButton(
                          buttonText: "Scan Code",
                          onPressed: () {},
                          iconPath: 'assets/images/scan.svg',
                          buttonHeight: size.height * 0.06,
                          backGroundColor: kBlackColor,
                          foreGroundColor: kWhiteColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomGradientButton(
                            text: "QR Code",
                            gradColors: kYellowGradColors,
                            prefixIconPath: 'assets/images/qr.svg',
                            buttonHeight: size.height * 0.06,
                            textColor: kBlackColor,
                            onPressed: () {}),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: kStockColor,
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PREFERENCE",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GT-Walsheim-Pro',
                          ),
                        ),
                        SizedBox(
                          height: size.width * 0.02,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SimpleList(items: preferenceList),
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        Text(
                          "FEEDBACK",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GT-Walsheim-Pro',
                          ),
                        ),
                        SizedBox(
                          height: size.width * 0.02,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SimpleList(items: feedbackList),
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: SimpleButton(
                              buttonText: "Logout",
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    onBoardingPageRoute,
                                    (Route<dynamic> route) => false);
                              },
                              iconPath: 'assets/images/logout.svg',
                              buttonHeight: size.height * 0.07,
                              backGroundColor: kRedColor,
                              foreGroundColor: kWhiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
