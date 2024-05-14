import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:o3d/o3d.dart';
import 'package:path/path.dart' as Path;
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:screenshot/screenshot.dart';

import '../features/entities/model_entity_internet.dart';
import '../ultil/snack_bar.dart';

class AddModelFromInternetProvider with ChangeNotifier {
  static final AddModelFromInternetProvider provider =
      AddModelFromInternetProvider._internal();

  factory AddModelFromInternetProvider() {
    return provider;
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AddModelFromInternetProvider._internal();

  RoundedLoadingButtonController buttonControllerSaveModel =
      RoundedLoadingButtonController();
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
  ModelEntityInternet newModel = ModelEntityInternet(
    imagePath: '',
    modelPath: '',
    id: '',
  );

  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? imageBytes;

  setModelPath(String path) {
    newModel = newModel.copyWith(modelPath: path);
    notifyListeners();
  }

  setImagePath(String path) {
    newModel = newModel.copyWith(imagePath: path);
    notifyListeners();
  }

  void takeScreenShoot() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      screenshotController.capture().then((img) {
        imageBytes = img;
        isLoadingAddModelInternet = false;
        notifyListeners();
      });
    });
  }

  deleteModelById(String id) async {
    try {
      await _firestore.collection('models').doc(id).delete();
    } catch (e) {
      print('Error deleting model from Firestore: $e');
    }
  }

  Future<String> reloadO3Model() {
    Future.delayed(const Duration(seconds: 1), () {});
    return Future.value(scannedResult);
  }

  Stream<List<ModelEntityInternet>> getAllPathsLocal() {
    CollectionReference modelsCollection =
        FirebaseFirestore.instance.collection('models');

    return modelsCollection.snapshots().map((QuerySnapshot snapshot) {
      return snapshot.docs
          .map<ModelEntityInternet>((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return ModelEntityInternet.fromJson(data);
      }).toList();
    });
  }

  Future<void> checkConditionsSaveModelFirebase(BuildContext context) async {
    if (imageBytes == null) {
      ShowSnackBar(context: context, doesItAppearAtTheBottom: true)
          .showErrorSnackBar(message: 'No model selected');
      buttonControllerSaveModel.reset();
    } else {
      try {
        String imagePath = await uploadImage();
        if (imagePath == '') {
          ShowSnackBar(context: context, doesItAppearAtTheBottom: true)
              .showErrorSnackBar(message: 'Error uploading image');
          buttonControllerSaveModel.reset();
        } else {
          setImagePath(imagePath);
          ShowSnackBar(
                  context: context,
                  doesItAppearAtTheBottom: true,
                  color: Colors.blue.withOpacity(.4))
              .showErrorSnackBar(message: 'Model added successfully');
          await addModel(newModel);
          buttonControllerSaveModel.reset();
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<String> uploadImage() async {
    if (imageBytes != null) {
      try {
        String fileName = Path.basename("image3.jpg");
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = firebaseStorageRef.putData(imageBytes!);
        await uploadTask;
        String downloadUrl = await firebaseStorageRef.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  Future<void> addModel(ModelEntityInternet model) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('models').add(model.toJson());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error adding model to Firestore: $e');
    }
  }
}
