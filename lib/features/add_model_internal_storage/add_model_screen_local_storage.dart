import 'package:augmented_reality/features/add_model_internal_storage/views/add_model_body_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/add_model_from_internal_storage_provider.dart';
import '../../widgets/loading_button.dart';

class AddModelScreenLocalStorage extends StatefulWidget {
  const AddModelScreenLocalStorage({super.key});

  @override
  State<AddModelScreenLocalStorage> createState() =>
      _AddModelScreenLocalStorageState();
}

class _AddModelScreenLocalStorageState
    extends State<AddModelScreenLocalStorage> {
  @override
  Widget build(BuildContext context) {
    AddModelFromInternalStorageProvider modelProvider =
        Provider.of<AddModelFromInternalStorageProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Model'),
      ),
      body: const AddModelBodyLocalStorage(),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LoadingButton(
            buttonText: 'SAVE MODEL',
            onPressed: () async {
              await modelProvider.checkConditionsSaveModel(context);
            },
            controller: modelProvider.buttonControllerSaveModel,
          ),
        ),
      ),
    );
  }
}
