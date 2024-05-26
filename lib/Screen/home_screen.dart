// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:data_shelving/Screen/card_scanner_screen.dart';
import 'package:data_shelving/Screen/enhance_screen.dart';
import 'package:data_shelving/Screen/recognizer_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';

enum Feature { scanner, recognize, enhance }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker imagePicker;
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    initializeCamera();
  }

  initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isInit = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Access Error Handle
            break;
          default:
            // Handle other errors here
            break;
        }
      }
    });
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: MediaQuery.of(context).size.height - 250,
                child: isInit
                    ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller))
                    : Container(),
              ),
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
                      await controller.takePicture().then((value) {
                        if (value != null) {
                          File image = File(value.path);
                          processImage(image);
                        }
                      });
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

                        processImage(image);
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

  processImage(File imageFile) async {
    final editedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropper(
          image: imageFile.readAsBytesSync(), // <-- Uint8List of image
        ),
      ),
    );

    if (editedImage == null) {
      return;
    }
    imageFile.writeAsBytes(editedImage);
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      Widget selectedWidget;
      switch (currentFeature) {
        case Feature.scanner:
          selectedWidget = CardScanner(imageFile);
          break;
        case Feature.recognize:
          selectedWidget = RecognizerScreen(imageFile);
          break;
        case Feature.enhance:
          selectedWidget = EnhanceScreen(imageFile);
          break;
        default:
          selectedWidget = RecognizerScreen(imageFile);
          break;
      }
      return selectedWidget;
    }));
  }
}
