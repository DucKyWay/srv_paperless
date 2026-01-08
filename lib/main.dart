import 'package:flutter/material.dart';
import 'package:srv_paperless/screen/home_screen.dart';
import 'package:srv_paperless/theme/theme.dart';
import 'package:srv_paperless/view/loginpage.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(
      ThemeData.light().textTheme,
    );
    return MaterialApp(
      title: 'Flutter Demo',
      theme: materialTheme.light(),
      home: LoginPage(),
    );
  }
}