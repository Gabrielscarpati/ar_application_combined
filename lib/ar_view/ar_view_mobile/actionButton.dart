import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final Function onTap;
  final IconData icon;
  const ActionButtons({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.all(14.0),
        ),
        child: Icon(
          icon,
          size: 24.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
