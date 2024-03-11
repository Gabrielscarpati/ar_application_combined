import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoadingButton extends StatelessWidget {
  final String buttonText;
  final bool? isButtonEnabled;
  final RoundedLoadingButtonController controller;
  final void Function() onPressed;
  const LoadingButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.controller,
    this.isButtonEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RoundedLoadingButton(
        height: 44,
        width: 250,
        color: Colors.blueAccent,
        borderRadius: 30,
        controller: controller,
        onPressed: isButtonEnabled == null
            ? null
            : isButtonEnabled!
                ? onPressed
                : null,
        elevation: 3,
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
