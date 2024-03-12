import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../features/choose_screen /choose_screen.dart';
import '../ultil /snack_bar.dart';

class AddModelFromInternalStorageProvider with ChangeNotifier {
  static final AddModelFromInternalStorageProvider provider =
      AddModelFromInternalStorageProvider._internal();

  factory AddModelFromInternalStorageProvider() {
    return provider;
  }
  AddModelFromInternalStorageProvider._internal();

  final _storage = const FlutterSecureStorage();

  List<ModelSavedModel> listPaths = <ModelSavedModel>[];

  AddModelFromInternalStorageProvider._() {
    getAllPaths();
  }

  final isLoading = ValueNotifier(false);
  String pathModel = '';
  Uint8List? _imageBytesImage;

  set setPathModel(String value) => pathModel = value;
  set setImageBytesImage(Uint8List value) => _imageBytesImage = value;

  Future<String> _generatePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${_generateName()}.glb";
    return path;
  }

  Future<void> _secureStorage(ModelSavedModel model) async {
    await _storage.write(key: model.key, value: model.toJson());
  }

  Future<List<ModelSavedModel>> getAllPaths() async {
    final map = await _storage.readAll();
    final result = map.values.map((e) => ModelSavedModel.fromJson(e)).toList();
    listPaths = result;
    return result;
  }

  Future<String> _saveFileReturnPath({
    String? path,
    Uint8List? uint8list,
  }) async {
    final pathGenerate = await _generatePath();
    final fileDef = File(pathGenerate);
    await fileDef.create(recursive: true);
    if (path != null) {
      uint8list = await File(path).readAsBytes();
    }
    await fileDef.writeAsBytes(uint8list!);
    return pathGenerate;
  }

  Future<void> save() async {
    isLoading.value = true;
    final modelPath = await _saveFileReturnPath(path: pathModel);
    final imagePath = await _saveFileReturnPath(uint8list: _imageBytesImage);
    final model = ModelSavedModel(
      key: _generateName(),
      pathModel: modelPath,
      pathImage: imagePath,
    );
    await _secureStorage(model);
    listPaths.add(model);
    isLoading.value = false;
    pathModel = '';
    _imageBytesImage = null;
    notifyListeners();
  }

  String _generateName() {
    final path = DateTime.now().millisecondsSinceEpoch.toString();
    return path;
  }

  Future<void> deleteModelByKey(String key) async {
    ModelSavedModel? modelToDelete;
    for (var model in listPaths) {
      if (model.key == key) {
        modelToDelete = model;
        break;
      }
    }
    if (modelToDelete != null) {
      final modelFile = File(modelToDelete.pathModel);
      if (await modelFile.exists()) {
        await modelFile.delete();
      }
      final imageFile = File(modelToDelete.pathImage);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      await _storage.delete(key: key);

      listPaths.removeWhere((model) => model.key == key);
    }
    notifyListeners();
  }

  void goBackAddModel(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const ChooseScreen()),
      (Route<dynamic> route) => false,
    );
    notifyListeners();
  }

  RoundedLoadingButtonController buttonControllerSaveModel =
      RoundedLoadingButtonController();

  Future<void> checkConditionsSaveModel(BuildContext context) async {
    if (pathModel == '') {
      ShowSnackBar(context: context, doesItAppearAtTheBottom: true)
          .showErrorSnackBar(message: 'No model selected');
      buttonControllerSaveModel.reset();
    } else {
      try {
        await getAllPaths();
        await save();
        buttonControllerSaveModel.reset();
        goBackAddModel(context);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}

class ModelSavedModel {
  final String key;
  final String pathImage;
  final String pathModel;
  const ModelSavedModel({
    required this.key,
    required this.pathImage,
    required this.pathModel,
  });

  ModelSavedModel copyWith({
    String? key,
    String? pathImage,
    String? pathModel,
  }) {
    return ModelSavedModel(
      key: key ?? this.key,
      pathImage: pathImage ?? this.pathImage,
      pathModel: pathModel ?? this.pathModel,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      'pathImage': pathImage,
      'pathModel': pathModel,
    };
  }

  factory ModelSavedModel.fromMap(Map<String, dynamic> map) {
    return ModelSavedModel(
      key: map['key'] as String,
      pathImage: map['pathImage'] as String,
      pathModel: map['pathModel'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ModelSavedModel.fromJson(String source) =>
      ModelSavedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ModelSavedModel(key: $key, pathImage: $pathImage, pathModel: $pathModel)';

  @override
  bool operator ==(covariant ModelSavedModel other) {
    if (identical(this, other)) return true;

    return other.key == key &&
        other.pathImage == pathImage &&
        other.pathModel == pathModel;
  }

  @override
  int get hashCode => key.hashCode ^ pathImage.hashCode ^ pathModel.hashCode;
}
