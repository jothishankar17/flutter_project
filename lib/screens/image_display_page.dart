import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_page.dart';
import 'about_page.dart';
import 'help_page.dart';

//This class stores image data globally in memory
class ImageMemoryStore {
  static Uint8List? latestWebImage;
  static File? latestMobileImage;

  static List<Uint8List> uploadedWebImages = [];
  static List<File> uploadedMobileImages = [];

  static void addWebImage(Uint8List image) {
    latestWebImage = image;
    uploadedWebImages.add(image);
  }

  static void addMobileImage(File image) {
    latestMobileImage = image;
    uploadedMobileImages.add(image);
  }

  static void clearAll() {
    uploadedWebImages.clear();
    uploadedMobileImages.clear();
    latestWebImage = null;
    latestMobileImage = null;
  }
}

//Main Image Display Page as StatefulWidget
class ImageDisplayPage extends StatefulWidget {
  const ImageDisplayPage({super.key});

  @override
  State<ImageDisplayPage> createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  int _currentIndex = 0;

 //Bottom Navigation Tab Handler
  void _onBottomNavTap (int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => AboutPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => HelpPage()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final latestImageWidget = kIsWeb && ImageMemoryStore.latestWebImage != null
        ? Image.memory(ImageMemoryStore.latestWebImage!, height: 200)
        : (!kIsWeb && ImageMemoryStore.latestMobileImage != null
              ? Image.file(ImageMemoryStore.latestMobileImage!, height: 200)
              : Text("No Image Available"));

    final allImages = kIsWeb
        ? ImageMemoryStore.uploadedWebImages
        : ImageMemoryStore.uploadedMobileImages;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Uploaded Image",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text("Latest Uploaded Image", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              latestImageWidget,
              SizedBox(height: 30),
              Text("All Uploaded Images", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              allImages.isNotEmpty
                  ? SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: kIsWeb
                                ? Image.memory(allImages[index] as Uint8List)
                                : Image.file(allImages[index] as File),
                          );
                        },
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text("No Uploaded Images Yet."),
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
