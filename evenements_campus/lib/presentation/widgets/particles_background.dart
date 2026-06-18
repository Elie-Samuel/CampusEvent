import 'dart:math';
import 'package:flutter/material.dart';

class ParticlesBackground extends StatefulWidget {
  final Color? color;
  const ParticlesBackground({super.key, this.color});

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Generate 35 particles with random parameters
    for (int i = 0; i < 35; i++) {
      _particles.add(
        FloatingParticle(
          xRatio: _random.nextDouble(),
          yRatio: _random.nextDouble(),
          size: _random.nextDouble() * 4 + 2, // Sizes 2 to 6
          speed: _random.nextDouble() * 0.2 + 0.1, // Float speed
          alpha: _random.nextInt(120) + 40, // Alpha transparency
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: FloatingParticlesPainter(
            particles: _particles,
            animationValue: _controller.value,
            particleColor: widget.color ?? Colors.white,
          ),
          child: child,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}

class FloatingParticle {
  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;
  final int alpha;

  FloatingParticle({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.alpha,
  });
}

class FloatingParticlesPainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final double animationValue;
  final Color particleColor;

  FloatingParticlesPainter({
    required this.particles,
    required this.animationValue,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Calculate continuous vertical movement
      final double x = particle.xRatio * size.width;
      // Animate y coordinate smoothly based on speed and time
      final double y = ((particle.yRatio - (animationValue * particle.speed)) % 1.0) * size.height;
      
      final paint = Paint()
        ..color = particleColor.withAlpha(particle.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FloatingParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}