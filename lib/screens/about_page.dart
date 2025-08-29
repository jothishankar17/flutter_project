import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("App Name: OTP Generator", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Version: 1.0.0"),
            SizedBox(height: 10),
            Text(
              "This app is designed for secure OTP generation and verification.",
            ),
          ],
        ),
      ),
    );
  }
}
