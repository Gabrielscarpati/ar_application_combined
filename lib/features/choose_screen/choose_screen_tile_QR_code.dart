import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../widgets/custom_popup.dart';
import '../ar_view/ar_view_web.dart';

class ChooseScreenTileQRCode extends StatefulWidget {
  final String modelPath;
  final String imagePath;
  final Function onPressed;

  const ChooseScreenTileQRCode({
    super.key,
    required this.imagePath,
    required this.modelPath,
    required this.onPressed,
  });

  @override
  ChooseScreenTileQRCodeState createState() => ChooseScreenTileQRCodeState();
}

class ChooseScreenTileQRCodeState extends State<ChooseScreenTileQRCode> {
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
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              flex: 5,
              borderRadius: BorderRadius.circular(10.0),
              onPressed: (context) async {
                widget.onPressed();
              },
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 4,
                blurRadius: 5,
                offset: const Offset(2, 2),
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(-2, -2),
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(-2, 2),
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(2, -2),
              ),
            ],
          ),
          child: Container(
            height: 105,
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
                        child:
                            Image.network(widget.imagePath, fit: BoxFit.fill),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => ModelViewWeb(
                            path: widget.modelPath,
                          ),
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
                          child:
                              Image.network(widget.imagePath, fit: BoxFit.fill),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
