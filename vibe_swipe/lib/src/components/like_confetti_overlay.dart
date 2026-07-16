import 'dart:math';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class LikeConfettiOverlay extends StatefulWidget {
  const LikeConfettiOverlay({
    super.key,
    required this.child,
    required this.showConfetti,
  });

  final Widget child;
  final bool showConfetti;

  @override
  State<LikeConfettiOverlay> createState() => _LikeConfettiOverlayState();
}

class _LikeConfettiOverlayState extends State<LikeConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _particles = [];
  }

  @override
  void didUpdateWidget(LikeConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles = List.generate(30, (index) {
      return _Particle(
        x: 0.1 + _random.nextDouble() * 0.8,
        y: -0.05 - _random.nextDouble() * 0.1,
        size: 3.0 + _random.nextDouble() * 6.0,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        fallSpeed: 0.5 + _random.nextDouble() * 0.5,
        swayAmplitude: 8.0 + _random.nextDouble() * 16.0,
        swayFrequency: 1.5 + _random.nextDouble() * 2.0,
        shape: _ParticleShape.values[_random.nextInt(_ParticleShape.values.length)],
      );
    });
  }

  static const List<Color> _confettiColors = [
    Color(0xFF47C28B),
    Color(0xFFFBBF24),
    Color(0xFFF472B6),
    Color(0xFF60A5FA),
    Color(0xFFA78BFA),
    Color(0xFFFB923C),
    Color(0xFF34D399),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          widget.child,
          if (_controller.isAnimating || _controller.isCompleted)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return IgnorePointer(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

enum _ParticleShape { circle, rectangle, spiral }

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double fallSpeed;
  final double swayAmplitude;
  final double swayFrequency;
  final _ParticleShape shape;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.fallSpeed,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final elapsed = progress;
      final fallY = p.y + elapsed * p.fallSpeed * 1.5;
      if (fallY > 1.1) continue;

      final swayX = p.x * size.width + sin(elapsed * p.swayFrequency * pi * 2) * p.swayAmplitude;
      final drawY = fallY * size.height;

      final fadeOut = elapsed > 0.7 ? 1.0 - ((elapsed - 0.7) / 0.3) : 1.0;
      final paint = Paint()
        ..color = p.color.withValues(alpha: fadeOut * 0.9)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(swayX, drawY);
      canvas.rotate(p.rotation + elapsed * p.rotationSpeed);

      switch (p.shape) {
        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case _ParticleShape.rectangle:
          final rect = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size * 0.5, height: p.size),
            Radius.circular(p.size * 0.15),
          );
          canvas.drawRRect(rect, paint);
          break;
        case _ParticleShape.spiral:
          _drawSpiral(canvas, p.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawSpiral(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final turns = 2.0;
    final points = 30;
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final angle = t * turns * 2 * pi;
      final radius = t * size * 0.4;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    paint.strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
