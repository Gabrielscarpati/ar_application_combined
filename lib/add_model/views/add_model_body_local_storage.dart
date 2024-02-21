import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:o3d/o3d.dart';
import 'package:screenshot/screenshot.dart';

class AddModelBodyLocalStorage extends StatefulWidget {
  const AddModelBodyLocalStorage({super.key});

  @override
  State<AddModelBodyLocalStorage> createState() =>
      _AddModelBodyLocalStorageState();
}

class _AddModelBodyLocalStorageState extends State<AddModelBodyLocalStorage> {
  O3DController controller = O3DController();

  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? _imageBytes;
  String? _modelPath;

  DateTime _previousTime = DateTime.now();
  List<int> differenceList = [];

  @override
  Widget build(BuildContext context) {
    void _takeAndMeasureScreenshot(String? filePath) async {
      try {
        // Record the start time
        DateTime startTime = DateTime.now();

        // Capture the screenshot
        Uint8List? imageBytes = await screenshotController.capture();

        // Record the end time
        DateTime endTime = DateTime.now();

        Duration duration = endTime.difference(startTime);
        print('Screenshot captured in ${duration.inMilliseconds} milliseconds');

        setState(() {
          _imageBytes = imageBytes;
        });
        if (filePath != null) {}
      } catch (e) {
        print("Error: $e");
      }
    }

    void _calculateTimeDifference() {
      DateTime currentTime = DateTime.now();

      int difference = currentTime.difference(_previousTime).inMilliseconds;
      differenceList.add(difference);
      print('Time difference: $differenceList milliseconds');
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Screenshot(
            controller: screenshotController,
            child: SizedBox(
              height: 150,
              width: 300,
              child: ModelViewer(
                backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                src: _modelPath ?? 'assets/glb/Duck.glb',
                alt: 'A 3D model of an astronaut',
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles();
                    File file = File(result?.files.single.path ?? "");
                    setState(() {
                      _modelPath = file.path;
                      _modelPath = "file:/${_modelPath!}";
                    });
                    print(_modelPath.toString() + "aaaaaaaaa");

                    _takeAndMeasureScreenshot(_modelPath);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const ListTile(
                      title: Text('Add Model from Local Storage'),
                      leading: Icon(Icons.folder),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _imageBytes != null ? Image.memory(_imageBytes!) : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
