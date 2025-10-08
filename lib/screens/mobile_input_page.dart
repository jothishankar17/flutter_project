// import 'package:flutter/material.dart';
// import 'otp_verification_page.dart';
// import 'home_page.dart';
// import 'about_page.dart';
// import 'help_page.dart';

// class MobileInputPage extends StatefulWidget {
//   const MobileInputPage({super.key});

//   @override
//   State<MobileInputPage> createState() => _MobileInputPageState();
// }

// class _MobileInputPageState extends State<MobileInputPage> {
//   final TextEditingController _mobileController = TextEditingController();
//   int _currentIndex = 0;

//   void _generateOTP() {
//     final mobileNumber = _mobileController.text.trim();

//     if (mobileNumber.length != 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OTPVerificationPage(mobileNumber: mobileNumber),
//       ),
//     );
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
//           "OTP Generator",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.blue,
//         centerTitle: false,
//       ),
//       backgroundColor: Colors.blue[50],
//       body: Center(
//         child: Container(
//           width: 320,
//           padding: EdgeInsets.all(20),
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
//                 "Enter Mobile Number",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),

//               SizedBox(height: 20),

//               TextField(
//                 controller: _mobileController,
//                 keyboardType: TextInputType.phone,
//                 maxLength: 10,
//                 decoration: InputDecoration(
//                   labelText: "Mobile Number",
//                   labelStyle: TextStyle(color: Colors.black),
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),

//               ElevatedButton(
//                 onPressed: _generateOTP,
//                 child: Text(
//                   "Generate OTP",
//                   style: TextStyle(color: Colors.blue),
//                 ),
//               ),
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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_verification_page.dart';
import 'home_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import '../firebase_options.dart';

class MobileInputPage extends StatefulWidget {
  const MobileInputPage({super.key});

  @override
  State<MobileInputPage> createState() => _MobileInputPageState();
}

class _MobileInputPageState extends State<MobileInputPage> {
  final TextEditingController _mobileController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  int _currentIndex = 0;

  // Initialize Firebase (only once)
  Future<void> _ensureFirebaseInitialized() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // If already initialized, ignore
    }
  }

  // ✅ Send OTP using Firebase
  Future<void> _sendOTP() async {
    final mobileNumber = _mobileController.text.trim();

    if (mobileNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _ensureFirebaseInitialized();

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$mobileNumber', // Add +country code
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification for some Android devices
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sending failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              mobileNumber: mobileNumber,
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout if needed
      },
      timeout: const Duration(seconds: 60),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OTP Generator",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: false,
      ),
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Mobile Number",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.blue),
                      ),
                      child: const Text(
                        "Generate OTP",
                        style: TextStyle(color: Colors.blue),
                      ),
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
