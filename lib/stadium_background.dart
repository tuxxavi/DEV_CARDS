// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dev_cards/particle_explosion_layer.dart';

class StadiumBackground extends StatelessWidget {
  final bool animate;
  const StadiumBackground({super.key, required this.animate});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.3,
          colors: [Color(0xFF2A003E), Color(0xFF000000)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: 120,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(1.35),
              child: CustomPaint(
                painter: StadiumGridPainter(),
                size: Size.infinite,
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.purpleAccent,
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
                color: Colors.purpleAccent.withOpacity(0.8),
              ),
            ),
          ),
          if (animate)
            Positioned.fill(
              child: const AmbientParticles(),
            ), // Partículas ambientales en el estadio
        ],
      ),
    );
  }
}

class StadiumGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = max(size.width, size.height) * 1.2;
    for (double i = 1; i <= 6; i++) {
      canvas.drawCircle(center, maxRadius * (i / 6), paint);
    }
    for (double i = 0; i < 16; i++) {
      final angle = (i * pi) / 8;
      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(angle) * maxRadius,
          center.dy + sin(angle) * maxRadius,
        ),
        paint,
      );
    }
    canvas.drawCircle(
      center,
      maxRadius * 0.1,
      Paint()
        ..color = Colors.purpleAccent.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    ); // Centro brillante
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
