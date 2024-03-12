import 'package:augmented_reality/ultil%20/future_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/add_model_from_internal_storage_provider.dart';
import '../add_model/add_model_screen.dart';
import 'choose_screen_tile.dart';

class ChooseScreen extends StatefulWidget {
  const ChooseScreen({super.key});

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  @override
  Widget build(BuildContext context) {
    AddModelFromInternalStorageProvider modelProvider =
        Provider.of<AddModelFromInternalStorageProvider>(context, listen: true);

    List<ModelSavedModel> listPaths = modelProvider.listPaths;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose ar Model'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DSFutureBuilder<List<ModelSavedModel>>(
              future: modelProvider.getAllPaths(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: listPaths.length,
                  itemBuilder: (context, index) {
                    final item = listPaths[index];
                    return ChooseScreenTile(
                      imagePath: item.pathImage,
                      modelPath: "file://${item.pathModel}",
                      modelKey: item.key,
                      onPressed: () async {
                        await modelProvider.deleteModelByKey(item.key);
                      },
                    );
                  },
                );
              },
              messageWhenEmpty: const Padding(
                padding:
                    EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                child: Text(
                    'There are no models saved, click on the + to add a new model.'),
              ),
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
              CupertinoPageRoute(builder: (context) => const AddModelScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
