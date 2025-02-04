import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/widgets/common/gradiant_end_text.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';

class EmptyTransactions extends StatelessWidget {
  final bool isPersonal;

  const EmptyTransactions({super.key, required this.isPersonal});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    Size size = MediaQuery.of(context).size;
    final String userName = user.name;

    final String buttonText =
        isPersonal ? 'Add more friends' : 'Start a new group';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(size.width * 0.0222),
            child: GradiantEndText(
              leadingText: 'Welcome to Splitemate, ',
              endingText: '$userName!',
            )),
        SizedBox(
          height: size.width * 0.0222,
        ),
        Image.asset('assets/images/welcome_character.png'),
        SizedBox(
          height: size.width * 0.0222,
        ),
        const Text(
          textAlign: TextAlign.center,
          'Easily track and manage transactions with individual friends or contacts',
          style: TextStyle(color: kGreyColor),
        ),
        Padding(
          padding: EdgeInsets.all(size.width * 0.0667),
          child: CustomGradientButton(
              text: buttonText,
              onPressed: () => {},
              gradColors: kGradColors,
              prefixIconPath: 'assets/images/add_friend.svg',
              buttonHeight: size.width * 0.1333),
        )
      ],
    );
  }
}
