import 'package:flutter/material.dart';

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  String imgUrl2 =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqjWX1pUn5nNbIl6jQ8_F5EOC1-_v5qexyqA&usqp=CAU';
  String imgUrl =
      "https://hbancroft.scusd.edu/sites/main/files/main-images/camera_lense_0.jpeg";
  String modelTwo =
      "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/2CylinderEngine/glTF-Binary/2CylinderEngine.glb";
  String modelOne =
      "https://modelviewer.dev/shared-assets/models/Astronaut.glb";

  List<ModelsListViewModel> modelsListViewModel = [];

  List<ModelsListViewModel> getModelsListViewModel() {
    modelsListViewModel.clear();
    modelsListViewModel.add(ModelsListViewModel(
      name: "name",
      image: imgUrl,
      modelUrl: modelOne,
    ));
    modelsListViewModel.add(ModelsListViewModel(
      name: "name",
      image: imgUrl,
      modelUrl: modelOne,
    ));
    modelsListViewModel.add(ModelsListViewModel(
      name: "name",
      image: imgUrl,
      modelUrl: modelOne,
    ));
    modelsListViewModel.add(ModelsListViewModel(
      name: "name",
      image: imgUrl2,
      modelUrl: modelTwo,
    ));
    modelsListViewModel.add(ModelsListViewModel(
      name: "name",
      image: imgUrl2,
      modelUrl: modelTwo,
    ));
    modelsListViewModel.add(ModelsListViewModel(
      name: "name",
      image: imgUrl2,
      modelUrl: modelTwo,
    ));
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
