import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoginBackgroundAnimation extends StatefulWidget {
  final Widget child;

  const LoginBackgroundAnimation({
    super.key,
    required this.child,
  });

  @override
  State<LoginBackgroundAnimation> createState() => _LoginBackgroundAnimationState();
}

class _LoginBackgroundAnimationState extends State<LoginBackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Floating elements animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.linear,
    ));

    // Start animations
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated background
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: LoginBackgroundPainter(
                floatingProgress: _floatingAnimation.value,
              ),
            );
          },
        ),
        
        // Content overlay
        widget.child,
      ],
    );
  }
}

class LoginBackgroundPainter extends CustomPainter {
  final double floatingProgress;

  LoginBackgroundPainter({
    required this.floatingProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw subtle floating icons
    _drawFloatingIcons(canvas, size, paint);
    
    // Draw corner decorations
    _drawCornerDecorations(canvas, size, paint);
  }

  void _drawFloatingIcons(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    final icons = [
      {'x': size.width * 0.15, 'y': size.height * 0.2, 'type': 'heart', 'phase': 0.0},
      {'x': size.width * 0.85, 'y': size.height * 0.15, 'type': 'star', 'phase': 0.3},
      {'x': size.width * 0.1, 'y': size.height * 0.7, 'type': 'target', 'phase': 0.6},
      {'x': size.width * 0.9, 'y': size.height * 0.8, 'type': 'trophy', 'phase': 0.9},
    ];

    for (var icon in icons) {
      final x = icon['x'] as double;
      final y = (icon['y'] as double) + math.sin(floatingProgress * 2 * math.pi + (icon['phase'] as double) * 2 * math.pi) * 10;
      final opacity = (math.sin(floatingProgress * 2 * math.pi + (icon['phase'] as double) * 2 * math.pi) + 1) / 2 * 0.1;
      
      paint.color = const Color(0xFF4CAF50).withOpacity(opacity);
      
      switch (icon['type']) {
        case 'heart':
          _drawHeart(canvas, Offset(x, y), 8, paint);
          break;
        case 'star':
          _drawStar(canvas, Offset(x, y), 8, paint);
          break;
        case 'target':
          _drawTarget(canvas, Offset(x, y), 8, paint);
          break;
        case 'trophy':
          _drawTrophy(canvas, Offset(x, y), 8, paint);
          break;
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.6, center.dy - size * 0.3,
      center.dx - size * 0.6, center.dy - size * 0.8,
      center.dx, center.dy - size * 0.5,
    );
    path.cubicTo(
      center.dx + size * 0.6, center.dy - size * 0.8,
      center.dx + size * 0.6, center.dy - size * 0.3,
      center.dx, center.dy + size * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = i * math.pi / 5;
      final radius = i.isEven ? size : size * 0.5;
      final x = center.dx + math.cos(angle - math.pi / 2) * radius;
      final y = center.dy + math.sin(angle - math.pi / 2) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTarget(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(center, size * 0.7, paint);
    canvas.drawCircle(center, size * 0.4, paint);
    canvas.drawCircle(center, size * 0.1, paint);
  }

  void _drawTrophy(Canvas canvas, Offset center, double size, Paint paint) {
    // Simple trophy outline
    final rect = Rect.fromCenter(center: center, width: size * 1.2, height: size);
    canvas.drawOval(rect, paint);
    canvas.drawLine(
      Offset(center.dx, center.dy + size * 0.5),
      Offset(center.dx, center.dy + size * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size * 0.4, center.dy + size * 0.8),
      Offset(center.dx + size * 0.4, center.dy + size * 0.8),
      paint,
    );
  }


  void _drawCornerDecorations(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = const Color(0xFF4CAF50).withOpacity(0.05);

    // Top left corner
    final topLeftPath = Path();
    topLeftPath.moveTo(0, 40);
    topLeftPath.lineTo(0, 20);
    topLeftPath.quadraticBezierTo(0, 0, 20, 0);
    topLeftPath.lineTo(40, 0);
    canvas.drawPath(topLeftPath, paint);

    // Bottom right corner
    final bottomRightPath = Path();
    bottomRightPath.moveTo(size.width - 40, size.height);
    bottomRightPath.lineTo(size.width - 20, size.height);
    bottomRightPath.quadraticBezierTo(size.width, size.height, size.width, size.height - 20);
    bottomRightPath.lineTo(size.width, size.height - 40);
    canvas.drawPath(bottomRightPath, paint);
  }

  @override
  bool shouldRepaint(LoginBackgroundPainter oldDelegate) {
    return floatingProgress != oldDelegate.floatingProgress;
  }
}