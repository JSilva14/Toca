import 'package:flutter/material.dart';

ThemeData buildTheme() {
  // We're going to define all of our font styles
  // in this method:
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
        fontFamily: 'Merriweather',
        fontSize: 40.0,
        color: const Color.fromARGB(255, 0, 153, 76),
      ),
      title: base.title.copyWith(
        fontFamily: 'Merriweather',
        fontSize: 15.0,
        color: const Color(0xFF807A6B),
      ),
    );
  }

  // We want to override a default light blue theme.
  final ThemeData base = ThemeData.light();

  // And apply changes on it:
  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme),
    // New code:
    primaryColor: const Color.fromARGB(255, 0, 153, 76),
    indicatorColor: const Color.fromARGB(255, 255, 255, 255),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    accentColor: const Color(0xFFFFF8E1),
    iconTheme: IconThemeData(
      color: const Color.fromARGB(255, 255, 0, 0),
      size: 20.0,
    ),
    buttonColor: Colors.white,
  );
}