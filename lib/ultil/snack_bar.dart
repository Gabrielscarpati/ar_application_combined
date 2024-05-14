import 'package:flutter/material.dart';

class ShowSnackBar {
  int? durationInSeconds;
  BuildContext context;
  Color? color;
  bool? doesItAppearAtTheBottom;

  ShowSnackBar(
      {required this.context,
      this.color,
      this.durationInSeconds,
      this.doesItAppearAtTheBottom = false});

  void showErrorSnackBar(
      {required String message, Color? color, int? durationInSeconds}) {
    showSnackBar(
      message: message,
      backgroundColor: color ?? this.color ?? Colors.redAccent.withOpacity(0.7),
      durationInSeconds: durationInSeconds,
    );
  }

  void showSnackBar(
      {required String message,
      Color? backgroundColor,
      int? durationInSeconds}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      padding: const EdgeInsets.all(0),
      margin: EdgeInsets.only(
        bottom: doesItAppearAtTheBottom! ? 12 : 140,
        left: 16,
        right: 16,
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
        ),
      ),
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.horizontal,
      duration: durationInSeconds == null
          ? const Duration(seconds: 5)
          : Duration(seconds: durationInSeconds),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
