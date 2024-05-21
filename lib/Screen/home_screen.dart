// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:data_shelving/Screen/card_scanner_screen.dart';
import 'package:data_shelving/Screen/recognizer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';

enum Feature { scanner, recognize, enhance }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  var currentFeature = Feature.scanner;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 20,
        bottom: 10,
        left: 5,
        right: 5,
      ),
      child: Column(
        children: [
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        currentFeature = Feature.scanner;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.scanner,
                          size: 25,
                          color: (currentFeature == Feature.scanner)
                              ? Colors.black
                              : Colors.white,
                        ),
                        Text(
                          'Scan',
                          style: TextStyle(
                            color: (currentFeature == Feature.scanner)
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        currentFeature = Feature.recognize;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner,
                          size: 25,
                          color: (currentFeature == Feature.recognize)
                              ? Colors.black
                              : Colors.white,
                        ),
                        Text(
                          'Recognize',
                          style: TextStyle(
                            color: (currentFeature == Feature.recognize)
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        currentFeature = Feature.enhance;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_sharp,
                          size: 25,
                          color: (currentFeature == Feature.enhance)
                              ? Colors.black
                              : Colors.white,
                        ),
                        Text(
                          'Enhance',
                          style: TextStyle(
                            color: (currentFeature == Feature.enhance)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.black,
            child: Container(
              height: MediaQuery.of(context).size.height - 250,
            ),
          ),
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {},
                    child: const Icon(
                      Icons.rotate_left,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      XFile? xFile = await imagePicker.pickImage(
                          source: ImageSource.camera);
                      if (xFile != null) {
                        File image = File(xFile.path);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) {
                          return RecognizerScreen(image);
                        }));
                      }
                    },
                    child: const Icon(
                      Icons.camera,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      XFile? xFile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (xFile != null) {
                        File image = File(xFile.path);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) {
                          switch (currentFeature) {
                            case Feature.scanner:
                              CardScanner(image);
                              break;
                            case Feature.recognize:
                              RecognizerScreen(image);
                              break;
                            default:
                              CardScanner(image);
                              break;
                          }
                          return RecognizerScreen(image);
                        }));
                      }
                    },
                    child: const Icon(
                      Icons.image,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
