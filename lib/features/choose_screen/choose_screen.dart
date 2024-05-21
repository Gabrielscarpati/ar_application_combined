import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/add_model_from_internal_storage_provider.dart';
import '../../provider/add_model_from_internet_provider.dart';
import '../../ultil/ds_stream_builder.dart';
import '../../ultil/future_builder.dart';
import '../add_model_QR_code/add_model_screen_QR_code.dart';
import '../add_model_internal_storage/add_model_screen_local_storage.dart';
import '../entities/model_entity_internet.dart';
import 'choose_screen_tile_QR_code.dart';
import 'choose_screen_tile_local_storage.dart';

class ChooseScreen extends StatefulWidget {
  const ChooseScreen({super.key});

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  @override
  Widget build(BuildContext context) {
    // AddModelFromInternalStorageProvider addModelFromInternalStorageProvider =
    //     Provider.of<AddModelFromInternalStorageProvider>(context, listen: true);

    AddModelFromInternetProvider addModelInternetProvider =
        Provider.of<AddModelFromInternetProvider>(context, listen: true);

    // List<ModelSavedModel> listPaths =
    //     addModelFromInternalStorageProvider.listPaths;

    return kIsWeb
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Choose ar Model'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: DSStreamBuilder<List<ModelEntityInternet>>(
                    stream: addModelInternetProvider.getAllPathsLocal(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return ChooseScreenTileQRCode(
                            imagePath: item.imagePath,
                            modelPath: item.modelPath,
                            onPressed: () async {
                              await addModelInternetProvider
                                  .deleteModelById(item.id);
                            },
                          );
                        },
                      );
                    },
                    messageWhenEmpty: const Padding(
                      padding: EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 16),
                      child: Text(
                          'There are no models saved, click on the + to add a new model.'),
                    ),
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
                    CupertinoPageRoute(
                        builder: (context) => const AddModelScreenQRCode()),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Choose ar Model'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Consumer<AddModelFromInternalStorageProvider>(
                    builder: (context, addModelFromInternalStorageProvider, child) {
                      return DSFutureBuilder<List<ModelSavedModel>>(
                        future: addModelFromInternalStorageProvider.getAllPathsLocal(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                  'There are no models saved, click on the + to add a new model.'),
                            );
                          }
                          final listPaths = snapshot.data!;
                          return ListView.builder(
                            itemCount: listPaths.length,
                            itemBuilder: (context, index) {
                              final item = listPaths[index];
                              return ChooseScreenTileLocalStorage(
                                imagePath: item.pathImage,
                                modelPath: "file://${item.pathModel}",
                                onPressed: () async {
                                  await addModelFromInternalStorageProvider.deleteModelByKey(item.key);
                                  setState(() {}); // Force rebuild to update UI
                                },
                              );
                            },
                          );
                        }, messageWhenEmpty: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                              'There are no models saved, click on the + to add a new model.'),
                        ),
                      );
                    },
                  ),
                ),
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
                    CupertinoPageRoute(
                        builder: (context) =>
                            const AddModelScreenLocalStorage()),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          );
  }
}
