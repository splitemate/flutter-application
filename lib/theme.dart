import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';

const AppBarTheme appBarTheme = AppBarTheme(
  centerTitle: false,
  elevation: 0,
  color: kStockColor,
  iconTheme: IconThemeData(color: kBlackColor),
  titleTextStyle: TextStyle(
    color: kBlackColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
);

final tabBarTheme = TabBarTheme(
  indicatorSize: TabBarIndicatorSize.label,
  unselectedLabelColor: Colors.black54,
  indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(50),
    color: kStockColor,
  ),
);

final dividerTheme =
    const DividerThemeData().copyWith(thickness: 1.0, indent: 75.0);

ThemeData lightTheme(BuildContext context) => ThemeData.light().copyWith(
      primaryColor: kWhiteColor,
      scaffoldBackgroundColor: kStockColor,
      appBarTheme: appBarTheme,
      tabBarTheme: tabBarTheme,
      // dividerTheme: dividerTheme.copyWith(color: kIconLight),
      // iconTheme: IconThemeData(color: kIconLight),
      // textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
      //     .apply(displayColor: Colors.black),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

ThemeData darkTheme(BuildContext context) => ThemeData.light().copyWith(
    primaryColor: kWhiteColor,
    scaffoldBackgroundColor: kStockColor,
    tabBarTheme: tabBarTheme.copyWith(unselectedLabelColor: kBlackColor),
    appBarTheme: appBarTheme.copyWith(backgroundColor: kStockColor),
    dividerTheme: dividerTheme.copyWith(color: kStockColor),
    iconTheme: const IconThemeData(color: kBlackColor),
    textTheme: ThemeData.dark().textTheme.copyWith(
          bodySmall: const TextStyle(color: kBlackColor),
          bodyMedium: const TextStyle(color: kBlackColor),
          bodyLarge: const TextStyle(color: kBlackColor),
          labelSmall: const TextStyle(color: kBlackColor),
          labelMedium: const TextStyle(color: kBlackColor),
          labelLarge: const TextStyle(color: kBlackColor),
          displaySmall: const TextStyle(color: kBlackColor),
          displayMedium: const TextStyle(color: kBlackColor),
          displayLarge: const TextStyle(color: kBlackColor),
          titleLarge: const TextStyle(color: kBlackColor),
          titleMedium: const TextStyle(color: kBlackColor),
          titleSmall: const TextStyle(color: kBlackColor),
        ),
    visualDensity: VisualDensity.adaptivePlatformDensity);

bool isLightTheme(BuildContext context) {
  return MediaQuery.of(context).platformBrightness != Brightness.light;
}
