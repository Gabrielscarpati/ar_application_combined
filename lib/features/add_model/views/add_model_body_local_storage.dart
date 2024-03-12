import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:o3d/o3d.dart';
import 'package:screenshot/screenshot.dart';

import '../../../provider/add_model_from_internal_storage_provider.dart';

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
  final _storage = AddModelFromInternalStorageProvider();
  List<int> differenceList = [];

  Widget defaultWidget() {
    return Container();
  }

  late Widget item = defaultWidget();

  void takeAndMeasureScreenshot(String? filePath) async {
    try {
      Uint8List? imageBytes = await screenshotController.capture();
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Screenshot(
            controller: screenshotController,
            child: SizedBox(
              height: 193,
              width: 200,
              child: item,
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
              SizedBox(
                height: 193,
                width: 200,
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!)
                    : Container(),
              ),
              if (isLoading)
                const SizedBox(
                  height: 193,
                  width: 200,
                  child: Center(
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator()),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
