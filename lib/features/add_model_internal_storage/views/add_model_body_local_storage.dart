import 'dart:io';
import 'dart:typed_data';

import 'package:augmented_reality/ultil/snack_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path/path.dart' as path;
import 'package:screenshot/screenshot.dart';

import '../../../provider/add_model_from_internal_storage_provider.dart';

class AddModelBodyLocalStorage extends StatefulWidget {
  const AddModelBodyLocalStorage({super.key});

  @override
  State<AddModelBodyLocalStorage> createState() =>
      _AddModelBodyLocalStorageState();
}

class _AddModelBodyLocalStorageState extends State<AddModelBodyLocalStorage> {
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? _imageBytes;
  bool isLoading = false;
  final _storage = AddModelFromInternalStorageProvider();
  String? modelPath;

  Widget defaultWidget() {
    return Container();
  }

  late Widget item = defaultWidget();

  void takeAndMeasureScreenshot(String filePath) async {
    try {
      Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        setState(() {
          _imageBytes = imageBytes;
          _storage.setImageBytesImage = imageBytes;
          _storage.setPathModel = filePath;
        });
      }
    } catch (e) {
      debugPrint("TakeAndMeasureScreenshot: $e");
    }
  }

  Future<File> renameFile(File file) async {
    final newFileName = path.basename(file.path).replaceAll(' ', '_');
    final newPath =
        path.join(path.dirname(file.path), newFileName.toLowerCase());
    final newFile = await file.rename(newPath);
    return newFile;
  }

  void pickFile() async {
    try {
      setState(() {
        _imageBytes = null;
        isLoading = true;
        item = defaultWidget();
        modelPath = null;
      });
      _storage.clearStorage(); // Clear previous storage

      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path ?? "");
        file = await renameFile(file);
        final typeFile = path.extension(file.path);
        if (typeFile == ".glb") {
          setState(() {
            item = ModelViewer(
              backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
              src: "file://${file.path}",
              alt: 'A 3D model of an astronaut',
              autoRotate: true,
              cameraControls: true,
            );
            modelPath = file.path;
          });
          await Future.delayed(const Duration(seconds: 3));
          takeAndMeasureScreenshot(file.path);
        } else {
          if (!mounted) return;
          ShowSnackBar(
            context: context,
            doesItAppearAtTheBottom: true,
          ).showErrorSnackBar(
            message: "Please select a .glb file",
          );
        }
      } else {
        debugPrint("FilePicker: No file selected");
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("PickFile: $e");
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
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.8,
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
                onTap: () => pickFile(),
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
              if (_imageBytes != null)
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ModelViewer(
                    backgroundColor:
                        const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                    src: "file://$modelPath",
                    alt: 'A 3D model',
                    autoRotate: true,
                    cameraControls: true,
                  ),
                )
              else if (!isLoading && _imageBytes == null)
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: const Center(
                    child: Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
