import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/states_management/bloc/bnb/bnb_bloc.dart';
import 'package:splitemate/widgets/bnb/bnb_item.dart';
import 'package:splitemate/widgets/bnb/floating_central_button.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  void onTap(BuildContext context, int index) {
    BlocProvider.of<BnbBloc>(context).add(TabChange(tabIndex: index));
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return BlocBuilder<BnbBloc, BnbState>(
      buildWhen: (previous, current) {
        return previous.tabIndex != current.tabIndex;
      },
      builder: (context, state) {
        final currentIndex = state.tabIndex;
        return BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          color: kWhiteColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BottomNavItem(
                      size: size,
                      assetPath: 'assets/images/home_bnb.svg',
                      label: 'Home',
                      isActive: currentIndex == 0,
                      onTap: () => onTap(context, 0),
                      activeGradientColors: kGradColors,
                    ),
                    BottomNavItem(
                      size: size,
                      assetPath: 'assets/images/transaction_bnb.svg',
                      label: 'Transaction',
                      isActive: currentIndex == 1,
                      onTap: () => onTap(context, 1),
                      activeGradientColors: kGradColors,
                    ),
                    const SizedBox(width: 70),
                    BottomNavItem(
                      size: size,
                      assetPath: 'assets/images/statistics_bnb.svg',
                      label: 'Statistics',
                      isActive: currentIndex == 2,
                      onTap: () => onTap(context, 2),
                      activeGradientColors: kGradColors,
                    ),
                    BottomNavItem(
                      size: size,
                      assetPath: 'assets/images/account_bnb.svg',
                      label: 'Account',
                      isActive: currentIndex == 3,
                      onTap: () => onTap(context, 3),
                      activeGradientColors: kGradColors,
                    ),
                  ],
                ),
              ),
              const FloatingCentralButton(),
            ],
          ),
        );
      },
    );
  }
}
