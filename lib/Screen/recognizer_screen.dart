import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecognizerScreen extends StatefulWidget {
  File image;

  RecognizerScreen(this.image, {super.key});

  @override
  State<RecognizerScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  late TextRecognizer textRecognizer;

  @override
  void initState() {
    super.initState();

    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    doTextRecognition();
  }

  String results = "";

  doTextRecognition() async {
    InputImage inputImage = InputImage.fromFile(widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    results = recognizedText.text;
    setState(() {
      results;
    });
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Recognizer'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Image.file(widget.image),
              Card(
                margin: const EdgeInsets.all(5),
                color: Colors.blueAccent,
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Results',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Icon(
                              Icons.copy,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(results),
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