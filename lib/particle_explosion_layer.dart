// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ParticleExplosionLayer extends StatefulWidget {
  final Stream<Offset> triggerStream;
  const ParticleExplosionLayer({super.key, required this.triggerStream});
  @override
  State<ParticleExplosionLayer> createState() => _ParticleExplosionLayerState();
}

class _ParticleExplosionLayerState extends State<ParticleExplosionLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Particle> particles = [];
  final Random _rnd = Random();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.addListener(() {
      setState(() {
        for (var p in particles) {
          p.update();
        }
      });
    });
    _sub = widget.triggerStream.listen((offset) => _explode(offset));
  }

  void _explode(Offset origin) {
    particles.clear();
    for (int i = 0; i < 30; i++) {
      // Generar 30 partículas
      particles.add(_Particle(origin: origin, rnd: _rnd));
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(
          particles: particles,
          progress: _controller.value,
        ),
        child: Container(),
      ),
    );
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life;
  _Particle({required Offset origin, required Random rnd})
    : position = origin,
      velocity = Offset(
        (rnd.nextDouble() - 0.5) * 10,
        (rnd.nextDouble() - 0.5) * 10,
      ),
      color = [
        Colors.cyanAccent,
        Colors.yellowAccent,
        Colors.redAccent,
        Colors.white,
      ][rnd.nextInt(4)],
      size = rnd.nextDouble() * 8 + 2,
      life = 1.0;
  void update() {
    position += velocity;
    velocity += const Offset(0, 0.2);
    life -= 0.02;
  } // Gravedad y vida
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ParticlePainter({required this.particles, required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.life <= 0) continue;
      final paint = Paint()
        ..color = p.color.withOpacity(p.life.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

// Partículas ambientales para el menú
class AmbientParticles extends StatefulWidget {
  const AmbientParticles({super.key});
  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<AmbientParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    // Inicializar algunas partículas
    for (int i = 0; i < 20; i++) {
      _particles.add(_createAmbientParticle());
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _controller.addListener(() {
      setState(() {
        for (var p in _particles) {
          p.position += p.velocity;
          // Reiniciar si salen de pantalla (aproximado)
          if (p.position.dy < -50) {
            p.position = Offset(
              p.position.dx,
              MediaQuery.of(context).size.height + 50,
            );
          }
        }
      });
    });
  }

  _Particle _createAmbientParticle() {
    // Usamos la clase _Particle existente pero con velocidades muy lentas hacia arriba
    var p = _Particle(
      origin: Offset(_rnd.nextDouble() * 400, _rnd.nextDouble() * 800),
      rnd: _rnd,
    );
    p.velocity = Offset(
      (_rnd.nextDouble() - 0.5) * 0.5,
      -_rnd.nextDouble() * 1.0 - 0.2,
    );
    p.color = Colors.cyanAccent.withOpacity(0.2);
    p.life = 1.0; // Vida infinita en este contexto
    return p;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reutilizamos el painter, ignorando la vida
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(
          particles: _particles,
          progress: 0,
        ), // Progress no importa aquí
      ),
    );
  }
}
