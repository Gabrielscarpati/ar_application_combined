import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewWeb extends StatelessWidget {
  final String path;
  const ModelViewWeb({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModelViewer(
        src: path,
        alt: "A 3D model of an astronaut",
        ar: true,
        cameraControls: true,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
