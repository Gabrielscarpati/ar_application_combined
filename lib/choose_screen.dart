import 'package:flutter/material.dart';

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
                child: const Text('model 3d on Screen', style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Model3DScreen(
                      title: 'Model 3D on camera',
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
                child: const Text('model 3d on Camera', style: TextStyle(color: Colors.white),),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
