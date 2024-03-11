import 'dart:io';
import 'dart:typed_data';

import 'package:augmented_reality/provider/save_ar_provider.dart';
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
  bool isLoading = false;
  final _storage = SaveARProvider.instance;
  List<int> differenceList = [];

  Widget defaultWidget() {
    return Container();
  }

  late Widget item = defaultWidget();

  void takeAndMeasureScreenshot(String? filePath) async {
    try {
      DateTime startTime = DateTime.now();
      Uint8List? imageBytes = await screenshotController.capture();
      DateTime endTime = DateTime.now();

      Duration duration = endTime.difference(startTime);
      print('Screenshot captured in ${duration.inMilliseconds} milliseconds');
      print("takeAndMeasureScreenshot: " + "capturou tela");
      setState(() {
        _imageBytes = imageBytes;
      });
      _storage.setPathModel = filePath!;
      _storage.setImageBytesImage = imageBytes!;
    } catch (e) {
      print(" takeAndMeasureScreenshot: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        children: [
          Screenshot(
            controller: screenshotController,
            child: SizedBox(
              height: 150,
              width: 300,
              child: item,
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles();
                      setState(() {
                        _imageBytes = null;
                        isLoading = true;
                        item = defaultWidget();
                      });
                      File file = File(result?.files.single.path ?? "");
                      setState(() {
                        item = ModelViewer(
                          backgroundColor:
                              const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                          src: "file://${file.path}",
                          alt: 'A 3D model of an astronaut',
                        );
                      });
                      await Future.delayed(const Duration(seconds: 8));
                      takeAndMeasureScreenshot(file.path);
                      setState(() {
                        isLoading = false;
                      });
                    } catch (e) {
                      print("takeAndMeasureScreenshot: " + e.toString());
                    }
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
                Visibility(
                  visible: isLoading,
                  child: const CircularProgressIndicator(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
