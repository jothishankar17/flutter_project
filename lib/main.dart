import 'package:flutter/material.dart';
import 'screens/mobile_input_page.dart';

void main() {
  runApp(const OTPApp());
}

class OTPApp extends StatelessWidget {
  const OTPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MobileInputPage(),
    );
  }
}
