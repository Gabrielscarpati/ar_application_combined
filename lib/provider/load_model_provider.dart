import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:o3d/o3d.dart';
import 'package:screenshot/screenshot.dart';

class LoadModelProvider with ChangeNotifier {
  static final LoadModelProvider provider = LoadModelProvider._internal();

  factory LoadModelProvider() {
    return provider;
  }

  LoadModelProvider._internal();

  String scannedResult = '';
  Future<void> scanQRCode(BuildContext context) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!context.mounted) return;
      scannedResult = barcodeScanRes;
      takeScreenShoot();
      isLoadingAddModelInternet = true;
      notifyListeners();
    } on Exception catch (e) {
      print(e);
    }
  }

  bool isLoadingAddModelInternet = false;
  O3DController OD3controller = O3DController();

  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? imageBytes;

  void takeScreenShoot() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      screenshotController.capture().then((img) {
        imageBytes = img;
        isLoadingAddModelInternet = false;
        notifyListeners();
      });
    });
  }

  Future<String> reloadO3Model() {
    Future.delayed(const Duration(seconds: 1), () {});
    return Future.value(scannedResult);
  }
}
