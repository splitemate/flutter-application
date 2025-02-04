import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/states_management/bloc/splash/splash_bloc.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  final PageController _pageController = PageController();

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to Splite Mate',
      'description':
          'Your ultimate app for managing income and expenses effortlessly.',
      'image': 'assets/images/splash_01.png',
    },
    {
      'title': 'Simplify Your Finances',
      'description':
          'Track your spending and income with ease and stay on top of your finances.',
      'image': 'assets/images/splash_02.png',
    },
    {
      'title': 'Split Bills Effortlessly',
      'description':
          'Share expenses with friends and family, and keep track of who owes what.',
      'image': 'assets/images/splash_03.png',
    },
    {
      'title': 'Gain Insights',
      'description':
          'Get detailed reports and analytics to understand your financial habits better.',
      'image': 'assets/images/splash_04.png',
    }
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, signUpPageRoute);
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: kGreyColor),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocBuilder<SplashBloc, SplashState>(
            builder: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_pageController.hasClients &&
                    _pageController.page!.toInt() != state.tabIndex) {
                  _pageController.jumpToPage(state.tabIndex);
                }
              });
              return PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  context.read<SplashBloc>().add(TabChange(tabIndex: index));
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(onboardingData[index]['image']!,
                          height: size.height / 2, width: size.width),
                      SizedBox(height: size.height * 0.005),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.15),
                        child: index == 0
                            ? RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Welcome to ',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: kGradColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                        child: const Text(
                                          'Splite Mate',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                onboardingData[index]['title']!,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.10),
                        child: Text(
                          onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: size.height * 0.04,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: Column(
              children: [
                BlocBuilder<SplashBloc, SplashState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(onboardingData.length, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.01),
                              width: state.tabIndex == index
                                  ? size.width * 0.05
                                  : size.width * 0.025,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: state.tabIndex == index
                                    ? const LinearGradient(
                                        colors: kGradColors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color:
                                    state.tabIndex == index ? null : kGreyColor,
                                borderRadius: state.tabIndex == index
                                    ? BorderRadius.circular(size.width * 0.01)
                                    : BorderRadius.circular(size.width * 0.02),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: size.width * 0.06),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05),
                          child: CustomGradientButton(
                            text: state.tabIndex == onboardingData.length - 1
                                ? 'Get started'
                                : 'Next',
                            onPressed: () {
                              final splashBloc = context.read<SplashBloc>();
                              if (splashBloc.state.tabIndex <
                                  onboardingData.length - 1) {
                                splashBloc.add(TabChange(
                                    tabIndex: splashBloc.state.tabIndex + 1));
                              } else {
                                Navigator.pushNamed(context, signUpPageRoute);
                              }
                            },
                            gradColors: kGradColors,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
