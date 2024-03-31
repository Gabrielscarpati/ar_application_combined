import 'package:augmented_reality/features/add_model_QR_code/views/add_model_body_from_QRCode.dart';
import 'package:augmented_reality/provider/add_model_from_internet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/loading_button.dart';

class AddModelScreenQRCode extends StatefulWidget {
  const AddModelScreenQRCode({super.key});

  @override
  State<AddModelScreenQRCode> createState() => _AddModelScreenQRCodeState();
}

class _AddModelScreenQRCodeState extends State<AddModelScreenQRCode> {
  @override
  Widget build(BuildContext context) {
    AddModelFromInternetProvider modelProvider =
        Provider.of<AddModelFromInternetProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Model'),
      ),
      body: const AddModelBodyFromQRCOde(),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LoadingButton(
            buttonText: 'SAVE MODEL',
            onPressed: () async {
              await modelProvider.checkConditionsSaveModelFirebase(context);
            },
            controller: modelProvider.buttonControllerSaveModel,
          ),
        ),
      ),
    );
  }
}
