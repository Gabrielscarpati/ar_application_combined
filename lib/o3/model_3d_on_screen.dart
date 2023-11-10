
import 'package:flutter/material.dart';
import 'package:o3d/o3d.dart';

class Model3DScreen extends StatefulWidget {
  const Model3DScreen({super.key, required this.title});

  final String title;

  @override
  State<Model3DScreen> createState() => _Model3DScreen();
}

class _Model3DScreen extends State<Model3DScreen> {
  // to control the animation
  O3DController controller = O3DController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () => controller.cameraOrbit(20, 20, 5),
              icon: const Icon(Icons.change_circle)),
          IconButton(
              onPressed: () => controller.cameraTarget(1.2, 1, 4),
              icon: const Icon(Icons.change_circle_outlined)),
        ],
      ),
      body: O3D(
        controller: controller,
        src: 'assets/glb/jeff_johansen_idle.glb',
        disableZoom: true,
        disablePan: true,
        withCredentials:false,
        // bool? disablePan,
        // disableTap : true,
      ),
    );
  }
}
