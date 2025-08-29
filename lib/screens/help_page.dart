import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              "How to Use:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("1. Go to Home and enter your mobile number."),
            Text("2. Tap 'Generate OTP' to receive your OTP."),
            Text("3. Enter the OTP in the verification page."),
            Text("4. Press 'Verify OTP' to complete verification."),
            SizedBox(height: 20),
            Text(
              "FAQ:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Q: What if I don't receive an OTP?"),
            Text(
              "A: Ensure your mobile number is correct. This app does not send real SMS.",
            ),
          ],
        ),
      ),
    );
  }
}
