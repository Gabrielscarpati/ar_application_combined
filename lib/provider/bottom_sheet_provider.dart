import 'dart:io';

import 'package:flutter/material.dart';

import 'add_model_from_internal_storage_provider.dart';

class BottomSheetProvider with ChangeNotifier {
  static final BottomSheetProvider provider = BottomSheetProvider._internal();

  factory BottomSheetProvider() {
    return provider;
  }
  BottomSheetProvider._internal();

  bool isShowingAddModelBottomSheet = false;

  void showAddModelBottomSheet() {
    isShowingAddModelBottomSheet = true;
    notifyListeners();
  }

  void hideAddModelBottomSheet() {
    isShowingAddModelBottomSheet = false;
    notifyListeners();
  }

  Widget addModelButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      child: const Icon(Icons.add, size: 48),
    );
  }

  Widget displayAvailableModelsButton(String image, Function() onTap) {
    return InkWell(
      onTap: () {
        onTap.call();
      },
      child: Image.file(File(image)),
    );
  }

  final saveAR = AddModelFromInternalStorageProvider();

  List<ModelsListViewModel> modelsListViewModel = [];

  List<ModelsListViewModel> getModelsListViewModel() {
    modelsListViewModel.clear();
    print("aqui: " + saveAR.listPaths.toString());
    for (var element in saveAR.listPaths) {
      modelsListViewModel.add(ModelsListViewModel(
        name: element.key,
        image: element.pathImage,
        modelUrl: element.pathModel,
      ));
    }
    return modelsListViewModel;
  }
}

class ModelsListViewModel {
  String name;
  String image;
  String modelUrl;
  ModelsListViewModel(
      {required this.name, required this.image, required this.modelUrl});
}
