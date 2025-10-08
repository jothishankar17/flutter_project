// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'home_page.dart';
// import 'about_page.dart';
// import 'help_page.dart';
// import 'package:otp_page_flutter/screens/image_upload_page.dart';

// class OTPVerificationPage extends StatefulWidget {
//   final String mobileNumber;

//   const OTPVerificationPage({super.key, required this.mobileNumber});

//   @override
//   State<OTPVerificationPage> createState() => _OTPVerificationPageState();
// }

// class _OTPVerificationPageState extends State<OTPVerificationPage> {
//   String _enteredOTP = "";
//   late String _generatedOTP;
//   bool _showOTP = true;
//   int _currentIndex = 0;

//   /// Generate OTP when the page loads
//   @override
//   void initState() {
//     super.initState();
//     _generatedOTP = _generateRandomOTP();
//   }

//   String _generateRandomOTP() {
//     final random = Random();
//     return (100000 + random.nextInt(900000)).toString();
//   }

//   void _verifyOTP() {
//     if (_enteredOTP == _generatedOTP) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text("Success"),
//           content: Text("OTP Verified Successfully!"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => ImageUploadPage()),
//                 );
//               },
//               child: Text("OK", style: TextStyle(color: Colors.blue)),
//             ),
//           ],
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Invalid OTP")));
//     }
//   }

//   void _onBottomNavTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//     if (index == 0) {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
//     } else if (index == 1) {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage()));
//     } else if (index == 2) {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => HelpPage()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Verify OTP",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.blue,
//         centerTitle: true,
//       ),
//       backgroundColor: Colors.green[50],
//       body: Center(
//         child: Container(
//           width: 320,
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "OTP sent to +91 ${widget.mobileNumber}",
//                 style: TextStyle(fontSize: 16),
//               ),

//               SizedBox(height: 10),

//               if (_showOTP)
//                 Text(
//                   "Your OTP is: $_generatedOTP",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//               SizedBox(height: 20),

//               PinCodeTextField(
//                 appContext: context,
//                 length: 6,
//                 autoFocus: true,
//                 autoDismissKeyboard: false,
//                 keyboardType: TextInputType.number,
//                 animationType: AnimationType.fade,
//                 cursorColor: Colors.black,
//                 pinTheme: PinTheme(
//                   shape: PinCodeFieldShape.box,
//                   borderRadius: BorderRadius.circular(10),
//                   fieldHeight: 50,
//                   fieldWidth: 40,
//                   activeColor: Colors.blue,
//                   selectedColor: Colors.blue,
//                   inactiveColor: Colors.grey,
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     _enteredOTP = value;
//                   });
//                 },
//               ),

//               const SizedBox(height: 20),

//               ElevatedButton(
//                 onPressed: _verifyOTP,
//                 child: Text("Verify OTP", style: TextStyle(color: Colors.blue)),
//               ),

//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         fixedColor: Colors.blue,
//         onTap: _onBottomNavTap,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
//           BottomNavigationBarItem(icon: Icon(Icons.help), label: "Help"),
//         ],
//       ),
//     );
//   }
// }

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'home_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'package:otp_page_flutter/screens/image_upload_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPVerificationPage extends StatefulWidget {
  final String mobileNumber;

  const OTPVerificationPage({super.key, required this.mobileNumber});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _otpSent = false;
  bool _isVerifying = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  /// ✅ Send OTP to mobile number
  Future<void> _sendOTP() async {
    String phoneNumber = '+91${widget.mobileNumber.trim()}';
    setState(() {
      _otpSent = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _auth.signInWithCredential(credential);
        _navigateToNextPage();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OTP sent successfully')));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// ✅ Verify entered OTP
  Future<void> _verifyOTP() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);
      _navigateToNextPage();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid OTP. Please try again.')));
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  /// ✅ Navigate to next page after success
  void _navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ImageUploadPage()),
    );
  }

  /// ✅ Bottom nav navigation
  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HelpPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Verify OTP",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      backgroundColor: Colors.green[50],
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "OTP sent to +91 ${widget.mobileNumber}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                autoFocus: true,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                cursorColor: Colors.black,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.blue,
                  selectedColor: Colors.blue,
                  inactiveColor: Colors.grey,
                ),
                onChanged: (_) {},
              ),

              const SizedBox(height: 20),

              _isVerifying
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Verify OTP",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

              const SizedBox(height: 10),

              TextButton(onPressed: _sendOTP, child: const Text("Resend OTP")),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor: Colors.blue,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Help"),
        ],
      ),
    );
  }
}
