import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'auth/auth_checker.dart';

void main() {
  runApp(const WasteVisionApp());
}

class WasteVisionApp extends StatelessWidget {
  const WasteVisionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WasteVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green[700],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const CheckAuth(),
    );
  }
}