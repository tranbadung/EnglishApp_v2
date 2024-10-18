import 'package:flutter/material.dart';
import 'dart:math';

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.shade200.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3;
    const dashSpace = 5;

    double startY = 88;
    double endY = size.height / 1.3;

    for (double y = startY; y < endY; y += dashWidth + dashSpace) {
      canvas.drawLine(Offset(size.width / 2, y),
          Offset(size.width / 2, min(y + dashWidth, endY)), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class QuizScreenPath extends StatefulWidget {
  const QuizScreenPath({super.key});

  @override
  State<QuizScreenPath> createState() => _QuizScreenPathState();
}

class _QuizScreenPathState extends State<QuizScreenPath> {
  double calcPosition(double y) {
    return 12 * sin(y / 1);
  }

  Widget buildNode(int index, String imagePath) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 100, // Kích thước container
      height: 60, // Kích thước container
      margin: EdgeInsets.only(
        top: 20,
        left: (24 * calcPosition(index.toDouble()) <= 0)
            ? (24 * calcPosition(index.toDouble())).abs()
            : 0,
        right: (24 * calcPosition(index.toDouble()) >= 0)
            ? 24 * calcPosition(index.toDouble())
            : 0,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100,
            blurRadius: 19,
            spreadRadius: 0.1,
          )
        ],
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          // Điều chỉnh chiều cao khớp với container
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text(
          'Lộ trình học',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.purple.shade100,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Container giới thiệu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: const Text(
              'Unit 1: Chào hỏi hằng ngày',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Corner characters
                Positioned(
                  left: 20,
                  bottom: 100,
                  child: Container(
                      width: 200,
                      height: 199,
                      child: Image.asset(
                        'assets/images/Screenshot_2024-10-17_174845-removebg-preview.png',
                        fit: BoxFit.fitHeight,
                      )),
                ),
                Positioned(
                  right: 0,
                  top: 80,
                  child: Container(
                      width: 200,
                      height: 200,
                      child: Image.asset(
                        'assets/images/Screenshot_2024-10-17_174617-removebg-preview.png',
                        fit: BoxFit.fitHeight,
                      )),
                ),
                // Main content with dotted line
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      // Dotted line container
                      // Positioned.fill(
                      //   child: CustomPaint(
                      //     painter: DottedLinePainter(),
                      //   ),
                      // ),
                      // Nodes
                      ListView(
                        children: [
                          buildNode(0,
                              'assets/images/Screenshot_2024-10-17_165527-removebg-preview.png'),
                          buildNode(1,
                              'assets/images/Screenshot_2024-10-17_161446-removebg-preview.png'),
                          buildNode(2,
                              'assets/images/Screenshot_2024-10-17_161446-removebg-preview.png'),
                          buildNode(3,
                              'assets/images/Screenshot_2024-10-17_161446-removebg-preview.png'),
                          buildNode(4,
                              'assets/images/Screenshot_2024-10-17_161446-removebg-preview.png'),
                          buildNode(5,
                              'assets/images/Screenshot_2024-10-17_161446-removebg-preview.png'),
                          buildNode(6,
                              'assets/images/Screenshot_2024-10-17_163439-removebg-preview.png'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
