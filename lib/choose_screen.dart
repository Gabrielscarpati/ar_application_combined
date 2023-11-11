import 'package:flutter/material.dart';

import 'examples/objectgesturesexample_local_gltf.dart';
import 'examples/objectgesturesexample_web_glb.dart';
import 'o3/model_3d_on_screen.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Model3DScreen(
                      title: 'Model 3D on Screen',
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
                child: const Text(
                  'model 3d on Screen',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const ObjectGesturesWidgetWeb_glb(),
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
                child: const Text(
                  'Object Transformation Gestures web_glb',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const ObjectGesturesWidgetLocal_gltf(),
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
                child: const Text(
                  'Object Transformation Gestures Local_gltf',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
