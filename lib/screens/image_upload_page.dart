import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'image_display_page.dart';
import 'home_page.dart';
import 'about_page.dart';
import 'help_page.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  Uint8List? _webImage; //Holds image bytes if running on web
  io.File? _mobileImage; //Holds a File if running on Android/iOS
  final ImagePicker _picker = ImagePicker(); //Instance to access camera/gallery
  int _currentIndex = 0;

  // Pick Image from Gallery
  Future<void> _pickImageFromGallery() async {
    if (!kIsWeb) {
      // Request permission on mobile
      if (io.Platform.isAndroid || io.Platform.isIOS) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gallery permission denied")),
          );
          return;
        }
      }
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _mobileImage = null;
        });
      } else {
        setState(() {
          _mobileImage = io.File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  //Capture Image from Camera
  Future<void> _captureImageFromCamera() async {
    if (!kIsWeb) {
      // Request permission on mobile
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission denied")),
        );
        return;
      }
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _mobileImage = null;
        });
      } else {
        setState(() {
          _mobileImage = io.File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  // Upload Image Simulation
  void _uploadImage() {
    if (_webImage == null && _mobileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select or capture an image first"),
        ),
      );
      return;
    }

    //Store in-memory
    if (kIsWeb && _webImage != null) {
      ImageMemoryStore.addWebImage(_webImage!);
    } else if (!kIsWeb && _mobileImage != null) {
      ImageMemoryStore.addMobileImage(_mobileImage!);
    }

    //Show snackbar and navigate to display page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image Uploaded Successfully!")),
    );

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImageDisplayPage()),
      );
    });
  }

  //Bottom Nav Handling
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
    final imageWidget = kIsWeb
        ? (_webImage != null
              ? Image.memory(_webImage!, height: 200)
              : const Text("No image selected"))
        : (_mobileImage != null
              ? Image.file(_mobileImage!, height: 200)
              : const Text("No image selected"));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Image Upload",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget,
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.image, color: Colors.blue),
                label: const Text(
                  "Choose From Gallery",
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: _captureImageFromCamera,
                icon: Icon(Icons.camera_alt, color: Colors.blue),
                label: Text(
                  "Capture With Camera",
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text(
                  "Upload Image",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Help"),
        ],
      ),
    );
  }
}

// import 'dart:io' as io;
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'image_display_page.dart';
// import 'home_page.dart';
// import 'about_page.dart';
// import 'help_page.dart';

// class ImageUploadPage extends StatefulWidget {
//   const ImageUploadPage({super.key});

//   @override
//   State<ImageUploadPage> createState() => _ImageUploadPageState();
// }

// class _ImageUploadPageState extends State<ImageUploadPage> {
//   Uint8List? _webImage; // Holds image bytes if running on web
//   io.File? _mobileImage; // Holds a File if running on Android/iOS
//   final ImagePicker _picker =
//       ImagePicker(); // Instance to access camera/gallery
//   int _currentIndex = 0;

//   // Pick Image from Gallery
//   Future<void> _pickImageFromGallery() async {
//     if (!kIsWeb) {
//       if (io.Platform.isIOS) {
//         // ✅ iOS requires Photos permission
//         final permission = await Permission.photos.request();
//         if (!permission.isGranted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Gallery permission denied")),
//           );
//           return;
//         }
//       }
//       // ✅ Android does not need manual request (handled by image_picker)
//     }

//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       if (kIsWeb) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _webImage = bytes;
//           _mobileImage = null;
//         });
//       } else {
//         setState(() {
//           _mobileImage = io.File(pickedFile.path);
//           _webImage = null;
//         });
//       }
//     }
//   }

//   // Capture Image from Camera
//   Future<void> _captureImageFromCamera() async {
//     if (!kIsWeb) {
//       // Request permission on mobile
//       final permission = await Permission.camera.request();
//       if (!permission.isGranted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Camera permission denied")),
//         );
//         return;
//       }
//     }

//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       if (kIsWeb) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _webImage = bytes;
//           _mobileImage = null;
//         });
//       } else {
//         setState(() {
//           _mobileImage = io.File(pickedFile.path);
//           _webImage = null;
//         });
//       }
//     }
//   }

//   // Upload Image Simulation
//   void _uploadImage() {
//     if (_webImage == null && _mobileImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please select or capture an image first"),
//         ),
//       );
//       return;
//     }

//     // Store in-memory
//     if (kIsWeb && _webImage != null) {
//       ImageMemoryStore.addWebImage(_webImage!);
//     } else if (!kIsWeb && _mobileImage != null) {
//       ImageMemoryStore.addMobileImage(_mobileImage!);
//     }

//     // Show snackbar and navigate to display page
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Image Uploaded Successfully!")),
//     );

//     Future.delayed(const Duration(milliseconds: 500), () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const ImageDisplayPage()),
//       );
//     });
//   }

//   // Bottom Nav Handling
//   void _onBottomNavTap(int index) {
//     setState(() => _currentIndex = index);

//     if (index == 0) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const HomePage()),
//       );
//     } else if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const AboutPage()),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const HelpPage()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageWidget = kIsWeb
//         ? (_webImage != null
//               ? Image.memory(_webImage!, height: 200)
//               : const Text("No image selected"))
//         : (_mobileImage != null
//               ? Image.file(_mobileImage!, height: 200)
//               : const Text("No image selected"));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Image Upload",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.blue,
//       ),
//       backgroundColor: Colors.blue[50],
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               imageWidget,
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: _pickImageFromGallery,
//                 icon: const Icon(Icons.image, color: Colors.blue),
//                 label: const Text(
//                   "Choose From Gallery",
//                   style: TextStyle(color: Colors.blue),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton.icon(
//                 onPressed: _captureImageFromCamera,
//                 icon: const Icon(Icons.camera_alt, color: Colors.blue),
//                 label: const Text(
//                   "Capture With Camera",
//                   style: TextStyle(color: Colors.blue),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: _uploadImage,
//                 child: const Text(
//                   "Upload Image",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
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
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
//           BottomNavigationBarItem(icon: Icon(Icons.help), label: "Help"),
//         ],
//       ),
//     );
//   }
// }
