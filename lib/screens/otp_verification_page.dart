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

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'package:otp_page_flutter/screens/image_upload_page.dart';

class OTPVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final String verificationId;

  const OTPVerificationPage({
    super.key,
    required this.mobileNumber,
    required this.verificationId,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _isVerifying = false;
  int _currentIndex = 0;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Use the verificationId passed from the previous screen (no auto re-send)
    _verificationId = widget.verificationId;
  }

  /// Verify entered OTP using the verificationId
  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification ID missing. Please resend OTP.')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 OTP Verified Successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ImageUploadPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP: ${e.message ?? 'Try again'}')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  /// Resend OTP (calls Firebase again and updates _verificationId)
  Future<void> _resendOTP() async {
    setState(() => _isResending = true);
    final phoneNumber = '+91${widget.mobileNumber.trim()}';

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification (Android) — sign in and navigate
        await _auth.signInWithCredential(credential);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number automatically verified!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ImageUploadPage()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isResending = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📩 OTP resent successfully')),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

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
  void dispose() {
    _otpController.dispose();
    super.dispose();
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

              _isResending
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                  : TextButton(
                      onPressed: _resendOTP,
                      child: const Text("Resend OTP"),
                    ),
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
