// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MiniCardBack extends StatelessWidget {
  final double width;
  final double height;
  const MiniCardBack({super.key, this.width = 150, this.height = 230});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 3),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 15),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          color: Colors.cyanAccent.withOpacity(0.5),
          size: 40,
        ),
      ),
    );
  }
}
