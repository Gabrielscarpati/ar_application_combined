import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'examples/ar_view_mobile.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Column(
        children: [
          ChooseScreenTile(
            title: "Chicken",
            isLocalStorage: true,
            imagePath: "assets/Chicken_01/Chicken_01.gltf",
          ),
          ChooseScreenTile(
            title: "Engine",
            isLocalStorage: false,
            imagePath:
                "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/2CylinderEngine/glTF-Binary/2CylinderEngine.glb",
          ),
        ],
      ),
    );
  }
}

class ChooseScreenTile extends StatelessWidget {
  final String title;
  final bool isLocalStorage;
  final String imagePath;

  const ChooseScreenTile(
      {super.key,
      required this.title,
      required this.isLocalStorage,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => kIsWeb
                  ? const ModelViewWeb(
                      path:
                          "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
                    )
                  : ArViewMobile(
                      isLocalStorage: isLocalStorage,
                      imagePath: imagePath,
                    ),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xff003B95),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ModelViewWeb extends StatelessWidget {
  final String path;
  const ModelViewWeb({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      src: path,
      alt: "A 3D model of an astronaut",
      ar: true,
      cameraControls: true,
      backgroundColor: Colors.transparent,
      // Other attributes as needed
    );
  }
}
