import 'package:flutter/material.dart';

import 'package:toca/ui/screens/login.dart';
import 'package:toca/ui/screens/home.dart';
import 'package:toca/ui/theme.dart';
import 'package:toca/state_widget.dart';

void main() => runApp(StateWidget(
      child: TocaApp(),
    ),);

class TocaApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toca',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
