import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class EnhanceScreen extends StatefulWidget {
  File image;

  EnhanceScreen(this.image, {super.key});

  @override
  State<EnhanceScreen> createState() => _EnhanceScreenState();
}

class _EnhanceScreenState extends State<EnhanceScreen> {
  late img.Image inputImage;

  @override
  void initState() {
    super.initState();
    inputImage = img.decodeImage(widget.image.readAsBytesSync())!;
    enhanceImage();
  }

  enhanceImage() {
    img.Image temp = img.decodeImage(widget.image.readAsBytesSync())!;
    inputImage = img.adjustColor(temp, brightness: brightness);
    inputImage = img.contrast(inputImage, contrast: contrast);
    setState(() {
      inputImage;
    });
  }

  double contrast = 150;
  double brightness = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Enhance',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          InkWell(
            onTap: () async {
              final editedImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageFilters(
                    image: Uint8List.fromList(
                        img.encodePng(inputImage)), // <-- Uint8List of image
                  ),
                ),
              );

              if (editedImage == null) {
                return;
              }

              inputImage = img.decodeImage(editedImage)!;
              setState(() {
                inputImage;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.photo_filter),
            ),
          ),
          InkWell(
            onTap: () async {
              final result = await ImageGallerySaver.saveImage(
                  Uint8List.fromList(img.encodePng(inputImage)));
              print(result);
              SnackBar snackBar = const SnackBar(content: Text('Saved!'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.save_alt),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.grey,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.5,
                  margin: const EdgeInsets.all(15),
                  child: Image.memory(
                      Uint8List.fromList(img.encodeBmp(inputImage))),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.contrast,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    Expanded(
                      child: Slider(
                        value: contrast,
                        onChanged: (v) {
                          contrast = v;
                          enhanceImage();
                          setState(() {
                            contrast;
                          });
                        },
                        min: 80,
                        max: 200,
                        divisions: 12,
                        label: contrast.toStringAsFixed(2),
                        activeColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.brightness_7,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    Expanded(
                      child: Slider(
                        value: brightness,
                        onChanged: (v) {
                          brightness = v;
                          enhanceImage();
                          setState(() {
                            contrast;
                          });
                        },
                        min: 1,
                        max: 10,
                        divisions: 10,
                        label: brightness.toStringAsFixed(2),
                        activeColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
