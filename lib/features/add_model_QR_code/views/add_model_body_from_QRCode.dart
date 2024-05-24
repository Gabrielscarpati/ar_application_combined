import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:qrcode_reader_web/qrcode_reader_web.dart';
import 'package:screenshot/screenshot.dart';

import '../../../provider/add_model_from_internet_provider.dart';

class AddModelBodyFromQRCode extends StatefulWidget {
  const AddModelBodyFromQRCode({super.key});

  @override
  State<AddModelBodyFromQRCode> createState() => _AddModelBodyFromQRCodeState();
}

class _AddModelBodyFromQRCodeState extends State<AddModelBodyFromQRCode> {
  ScreenshotController screenshotController = ScreenshotController();
  String? modelPath;

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
                              child: ModelViewer(
                                backgroundColor: const Color.fromARGB(
                                    0xFF, 0xEE, 0xEE, 0xEE),
                                src: snapshot.data!,
                                alt: 'A 3D model of an astronaut',
                                disableZoom: true,
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
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _showDialogQRCode(loadModelProvider, context);
                        },
                      );
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
                        title: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code),
                              SizedBox(
                                  width: 8), // Espaço entre o ícone e o texto
                              Text('Add Model from QRCode'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (loadModelProvider.imageBytes != null)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ModelViewer(
                        backgroundColor:
                            const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                        src: loadModelProvider.scannedResult,
                        alt: 'A 3D model',
                        autoRotate: true,
                        cameraControls: true,
                      ),
                    )
                  else if (!loadModelProvider.isLoadingAddModelInternet &&
                      loadModelProvider.imageBytes == null)
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
                  if (loadModelProvider.isLoadingAddModelInternet)
                    const SizedBox(
                      height: 193,
                      width: 200,
                      child: Center(
                        child: SizedBox(
                            height: 100,
                            width: 100,
                            child: CircularProgressIndicator()),
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

  AlertDialog _showDialogQRCode(
      AddModelFromInternetProvider loadModelProvider, BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 300,
        width: 300,
        child: Column(
          children: [
            const Text('Scan QR Code'),
            const SizedBox(height: 20),
            Expanded(
              child: QRCodeReaderSquareWidget(
                onDetect: (QRCodeCapture capture) {
                  loadModelProvider.scanQRCode(context, capture.raw);
                  Navigator.pop(context);
                  setState(() {});
                },
                size: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
