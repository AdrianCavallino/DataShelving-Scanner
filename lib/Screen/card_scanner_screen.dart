import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardScanner extends StatefulWidget {
  File image;

  CardScanner(this.image, {super.key});

  @override
  State<CardScanner> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScanner> {
  late TextRecognizer textRecognizer;
  late EntityExtractor entityExtractor;

  List<EntityDataModel> entityList = [];

  @override
  void initState() {
    super.initState();

    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    entityExtractor =
        EntityExtractor(language: EntityExtractorLanguage.english);
    doTextRecognition();
  }

  String results = "";

  doTextRecognition() async {
    InputImage inputImage = InputImage.fromFile(widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    entityList.clear();
    results = recognizedText.text;
    final List<EntityAnnotation> annotations =
        await entityExtractor.annotateText(results);

    for (final annotation in annotations) {
      annotation.start;
      annotation.end;
      annotation.text;
      for (final entity in annotation.entities) {
        results += "${entity.type.name}\n${entity.rawValue}\n\n";
        entityList.add(EntityDataModel(entity.type.name, annotation.text));
      }
    }

    setState(() {
      results;
      entityList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Scanner',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Image.file(widget.image),
              ListView.builder(
                itemBuilder: (context, position) {
                  return Card(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    color: Colors.blueAccent,
                    child: Container(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              entityList[position].iconData,
                              size: 25,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Text(
                                entityList[position].value,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: entityList[position].value));
                                SnackBar snackBar =
                                    const SnackBar(content: Text("Copied"));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              child: const Icon(
                                Icons.copy,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: entityList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
              ),
              // Card(
              //   margin: const EdgeInsets.all(5),
              //   color: Colors.blueAccent,
              //   child: Column(
              //     children: [
              //       Container(
              //         child: Padding(
              //           padding: const EdgeInsets.only(
              //             top: 10,
              //             left: 10,
              //             right: 10,
              //           ),
              //           child: Row(
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               const Icon(
              //                 Icons.document_scanner,
              //                 color: Colors.white,
              //               ),
              //               const Text(
              //                 'Results',
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 18,
              //                 ),
              //               ),
              //               InkWell(
              //                 onTap: () {
              //                   Clipboard.setData(ClipboardData(text: results));
              //                   SnackBar snackBar =
              //                       const SnackBar(content: Text("Copied"));
              //                   ScaffoldMessenger.of(context)
              //                       .showSnackBar(snackBar);
              //                 },
              //                 child: const Icon(
              //                   Icons.copy,
              //                   color: Colors.white,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       Text(results),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntityDataModel {
  String name;
  String value;
  IconData? iconData;

  EntityDataModel(this.name, this.value) {
    if (name == "phone") {
      iconData = Icons.phone;
    } else if (name == "address") {
      iconData = Icons.location_on;
    } else if (name == "email") {
      iconData = Icons.mail;
    } else if (name == "url") {
      iconData = Icons.web;
    } else {
      iconData = Icons.ac_unit_outlined;
    }
  }
}
