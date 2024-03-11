import 'dart:io';

import 'package:augmented_reality/provider/save_ar_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'add_model/add_model_screen.dart';
import 'ar_view/ar_view_mobile/ar_view_mobile.dart';
import 'ar_view/ar_view_web.dart';
import 'widgets/custom_popup.dart';

class ChooseScreen extends StatefulWidget {
  const ChooseScreen({Key? key}) : super(key: key);

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  final _localModels = SaveARProvider.instance;

  var list = <ModelSavedModel>[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadingItens();
    });
    super.initState();
  }

  void loadingItens() async {
    _localModels.getAllPaths().then((list) {
      setState(() {
        this.list = (list);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose ar Model'),
      ),
      body: Column(
        children: [
          // const ChooseScreenTile(
          //   title: "Chicken",
          //   imagePath:
          //       'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return ChooseScreenTile(
                  imagePath: item.pathImage,
                  modelPath: "file://${item.pathModel}",
                  title: item.key,
                );
                // return ListTile(
                //   onTap: () {
                //     Navigator.push<void>(
                //       context,
                //       MaterialPageRoute<void>(
                //         builder: (BuildContext context) => CustomPopUp(
                //           title: 'Model Viewer',
                //           yesText: 'Save',
                //           widthYes: 100,
                //           noText: 'Go Back',
                //           widthNo: 100,
                //           body: ModelViewer(
                //             backgroundColor:
                //                 const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                //             src: "file://${item.pathModel}",
                //             alt: 'A 3D model of an astronaut',
                //             ar: false,
                //             autoRotate: false,
                //             disableZoom: true,
                //           ),
                //           onPressedNo: () {
                //             Navigator.pop(context);
                //           },
                //           onPressedYes: () async {},
                //         ),
                //       ),
                //     );
                //   },
                //   leading: Image.file(File(item.pathImage)),
                //   title: Text(item.key),
                // );
              },
            ),
          )
        ],
      ),
      floatingActionButton: SizedBox(
        height: 54,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          elevation: 5,
          shape: const CircleBorder(),
          onPressed: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const AddModelScreen()),
            );
            loadingItens();
          },
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class ChooseScreenTile extends StatefulWidget {
  final String title;
  final String modelPath;
  final String imagePath;

  const ChooseScreenTile({
    super.key,
    required this.title,
    required this.imagePath,
    required this.modelPath,
  });

  @override
  _ChooseScreenTileState createState() => _ChooseScreenTileState();
}

class _ChooseScreenTileState extends State<ChooseScreenTile> {
  late Widget modelViewLocal;

  @override
  void initState() {
    super.initState();
    modelViewLocal = buildModelViewer();
  }

  Widget buildModelViewer() {
    return ModelViewer(
      backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
      src: widget.modelPath,
      alt: 'A 3D model of an astronaut',
      ar: false,
      autoRotate: false,
      disableZoom: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Future popUpChangePassword(
      context,
    ) =>
        showDialog(
          context: context,
          builder: (context) => CustomPopUp(
            title: 'Model Viewer',
            yesText: 'Save',
            widthYes: 100,
            noText: 'Go Back',
            widthNo: 100,
            body: modelViewLocal,
            onPressedNo: () {
              Navigator.pop(context);
            },
            onPressedYes: () async {},
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 5,
              offset: const Offset(2, 2), // bottom-right side
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(-2, -2), // top-left side
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(-2, 2), // bottom-left side
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, -2), // top-right side
            ),
          ],
        ),
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('3D Model'),
                  InkWell(
                    onTap: () {
                      popUpChangePassword(context);
                    },
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.file(File(widget.imagePath)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
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
                            : ArViewMobile(),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AR Model'),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: Image.file(File(widget.imagePath)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
