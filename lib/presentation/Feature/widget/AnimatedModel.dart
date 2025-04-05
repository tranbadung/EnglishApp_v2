import 'package:flutter/material.dart';

class AnimatedModel extends StatelessWidget {
  final bool isSpeaking;

  const AnimatedModel({super.key, required this.isSpeaking});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: ClipOval( // Để cắt hình thành hình tròn
      child: SizedBox(
      width: 150,  // Kích thước hình tròn
      height: 150,
      child: isSpeaking
          ? Image.asset('assets/images/bear_open_mouth.gif') // Hình ảnh nhân vật mở miệng
          : Image.asset('assets/images/bear_closed_mouth.gif'), // Hình ảnh nhân vật đóng miệng
      ),
      ),
    );
  }
}