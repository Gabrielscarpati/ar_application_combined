import 'package:augmented_reality/add_model/views/add_model_body_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../widgets/loading_button.dart';

class AddModelScreen extends StatefulWidget {
  const AddModelScreen({super.key});

  @override
  State<AddModelScreen> createState() => _AddModelScreenState();
}

class _AddModelScreenState extends State<AddModelScreen> {
  RoundedLoadingButtonController controller = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              controller.reset();
            },
            controller: controller,
          ),
        ),
      ),
    );
  }
}
