import 'package:flutter/material.dart';

class CustomPopUp extends StatelessWidget {
  final String title;
  final Widget? body;
  final Function() onPressedYes;
  final Function() onPressedNo;
  final double? widthYes;
  final double? widthNo;
  final String yesText;
  final String noText;
  final EdgeInsetsGeometry? buttonPadding;
  final double? spaceBetweenButtons;

  const CustomPopUp({
    Key? key,
    required this.title,
    required this.onPressedYes,
    required this.onPressedNo,
    this.body,
    this.widthYes,
    this.widthNo,
    required this.yesText,
    required this.noText,
    this.buttonPadding,
    this.spaceBetweenButtons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
        ),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        insetPadding: const EdgeInsets.all(0),
        //titlePadding: const EdgeInsets.only(right: 16, bottom: 8, top: 16, left: 16),
        actionsPadding:
            const EdgeInsets.only(right: 16, bottom: 16, top: 16, left: 16),
        title: Text(
          title,
        ),
        content:
            SizedBox(width: MediaQuery.of(context).size.width, child: body),
        actions: [
          GestureDetector(
            onTap: onPressedNo,
            child: Container(
              padding: buttonPadding ?? const EdgeInsets.all(16),
              width: widthNo ?? 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  noText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
