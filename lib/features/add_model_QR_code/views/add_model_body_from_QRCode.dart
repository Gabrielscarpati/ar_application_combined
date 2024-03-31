import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:o3d/o3d.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../provider/add_model_from_internet_provider.dart';

class AddModelBodyFromQRCOde extends StatefulWidget {
  const AddModelBodyFromQRCOde({super.key});

  @override
  State<AddModelBodyFromQRCOde> createState() => _AddModelBodyFromQRCOdeState();
}

class _AddModelBodyFromQRCOdeState extends State<AddModelBodyFromQRCOde> {
  @override
  Widget build(BuildContext context) {
    AddModelFromInternetProvider loadModelProvider =
        context.watch<AddModelFromInternetProvider>();

    return Material(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: FutureBuilder<String>(
                    future: loadModelProvider.reloadO3Model(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Builder(
                          builder: (context) {
                            loadModelProvider.setModelPath(snapshot.data!);
                            return Screenshot(
                              controller:
                                  loadModelProvider.screenshotController,
                              child: O3D(
                                backgroundColor: const Color.fromARGB(
                                    0xFF, 0xEE, 0xEE, 0xEE),
                                src: snapshot.data!,
                                alt: 'A 3D model of an astronaut',
                                disableZoom: true,
                                controller: loadModelProvider.OD3controller,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  loadModelProvider.isLoadingAddModelInternet
                      ? const SizedBox(
                          height: 193,
                          width: 200,
                          child: Center(
                            child: SizedBox(
                                height: 100,
                                width: 100,
                                child: CircularProgressIndicator()),
                          ),
                        )
                      : Container(
                          height: 193,
                          width: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              alignment: FractionalOffset.bottomCenter,
                              image: MemoryImage(
                                  loadModelProvider.imageBytes ?? Uint8List(0)),
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        loadModelProvider.scanQRCode(context);
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
                          title: Text('Add Model from QRCode'),
                          leading: Icon(Icons.link),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
