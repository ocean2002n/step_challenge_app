import 'package:flutter/material.dart';
import 'dart:math' as math;

class RunningBackgroundAnimation extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;

  const RunningBackgroundAnimation({
    super.key,
    required this.child,
    this.primaryColor = Colors.green,
    this.secondaryColor = Colors.lightGreen,
  });

  @override
  State<RunningBackgroundAnimation> createState() => _RunningBackgroundAnimationState();
}

class _RunningBackgroundAnimationState extends State<RunningBackgroundAnimation>
    with TickerProviderStateMixin {
  late AnimationController _runnerController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  
  late Animation<double> _runnerAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Runner animation (跑步人物動畫)
    _runnerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Background movement (背景移動動畫)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    // Particle effects (粒子效果動畫)
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _runnerAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _runnerController,
      curve: Curves.linear,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _runnerController.repeat();
    _backgroundController.repeat();
    _particleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _runnerController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated background
        AnimatedBuilder(
          animation: Listenable.merge([_backgroundAnimation, _particleAnimation]),
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: RunningBackgroundPainter(
                backgroundProgress: _backgroundAnimation.value,
                particleProgress: _particleAnimation.value,
                primaryColor: widget.primaryColor,
                secondaryColor: widget.secondaryColor,
              ),
            );
          },
        ),
        
        // Running figure animation
        AnimatedBuilder(
          animation: _runnerAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: RunningFigurePainter(
                animationProgress: _runnerAnimation.value,
                primaryColor: widget.primaryColor.withOpacity(0.1),
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

class RunningBackgroundPainter extends CustomPainter {
  final double backgroundProgress;
  final double particleProgress;
  final Color primaryColor;
  final Color secondaryColor;

  RunningBackgroundPainter({
    required this.backgroundProgress,
    required this.particleProgress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw animated track lines (跑道線條)
    _drawTrackLines(canvas, size, paint);
    
    // Draw floating particles (浮動粒子)
    _drawParticles(canvas, size, paint);
    
    // Draw speed lines (速度線條)
    _drawSpeedLines(canvas, size, paint);
  }

  void _drawTrackLines(Canvas canvas, Size size, Paint paint) {
    paint.color = primaryColor.withOpacity(0.1);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    final offset = backgroundProgress * 100;
    
    for (int i = 0; i < 8; i++) {
      final y = (size.height / 8) * i;
      final startX = -100 + (offset % 200);
      
      final path = Path();
      path.moveTo(startX, y);
      path.lineTo(startX + size.width + 100, y);
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawParticles(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    
    final particles = List.generate(15, (index) {
      final x = (size.width / 15) * index + (backgroundProgress * 50) % size.width;
      final y = (size.height / 3) + math.sin(particleProgress * 2 * math.pi + index) * 20;
      final opacity = (math.sin(particleProgress * 2 * math.pi + index * 0.5) + 1) / 2;
      
      return {'x': x, 'y': y, 'opacity': opacity};
    });

    for (var particle in particles) {
      paint.color = secondaryColor.withOpacity((particle['opacity'] as double) * 0.3);
      canvas.drawCircle(
        Offset(particle['x'] as double, particle['y'] as double),
        3,
        paint,
      );
    }
  }

  void _drawSpeedLines(Canvas canvas, Size size, Paint paint) {
    paint.color = primaryColor.withOpacity(0.2);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final progress = (backgroundProgress + i * 0.1) % 1.0;
      final x = size.width * progress;
      final startY = size.height * 0.6;
      final endY = startY + 40;
      
      final opacity = 1 - progress;
      paint.color = primaryColor.withOpacity(opacity * 0.3);
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x - 20, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RunningBackgroundPainter oldDelegate) {
    return backgroundProgress != oldDelegate.backgroundProgress ||
           particleProgress != oldDelegate.particleProgress;
  }
}

class RunningFigurePainter extends CustomPainter {
  final double animationProgress;
  final Color primaryColor;

  RunningFigurePainter({
    required this.animationProgress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Position the runner in the background
    final centerX = size.width * 0.8;
    final centerY = size.height * 0.7;
    
    _drawRunningFigure(canvas, centerX, centerY, paint);
  }

  void _drawRunningFigure(Canvas canvas, double centerX, double centerY, Paint paint) {
    // Running cycle animation (跑步週期動畫)
    final legCycle = math.sin(animationProgress * 4);
    final armCycle = math.sin(animationProgress * 4 + math.pi);
    final bounce = (math.sin(animationProgress * 4)).abs() * 5;
    
    final runnerY = centerY - bounce;

    // Head (頭部)
    canvas.drawCircle(Offset(centerX, runnerY - 30), 8, paint);
    
    // Body (身體)
    canvas.drawLine(
      Offset(centerX, runnerY - 22),
      Offset(centerX, runnerY + 20),
      paint,
    );
    
    // Arms (手臂)
    final leftArmX = centerX - 15 + armCycle * 8;
    final leftArmY = runnerY - 10 + armCycle * 5;
    canvas.drawLine(
      Offset(centerX, runnerY - 10),
      Offset(leftArmX, leftArmY),
      paint,
    );
    
    final rightArmX = centerX + 15 - armCycle * 8;
    final rightArmY = runnerY - 10 - armCycle * 5;
    canvas.drawLine(
      Offset(centerX, runnerY - 10),
      Offset(rightArmX, rightArmY),
      paint,
    );
    
    // Legs (腿部)
    final leftLegX = centerX - 10 + legCycle * 15;
    final leftLegY = runnerY + 35 + legCycle.abs() * 10;
    canvas.drawLine(
      Offset(centerX, runnerY + 20),
      Offset(leftLegX, leftLegY),
      paint,
    );
    
    final rightLegX = centerX + 10 - legCycle * 15;
    final rightLegY = runnerY + 35 + (-legCycle).abs() * 10;
    canvas.drawLine(
      Offset(centerX, runnerY + 20),
      Offset(rightLegX, rightLegY),
      paint,
    );

    // Motion blur effect (運動模糊效果)
    paint.color = primaryColor.withOpacity(0.3);
    paint.strokeWidth = 1;
    
    // Previous position shadow
    final prevX = centerX + 10;
    _drawSimpleFigure(canvas, prevX, runnerY + 2, paint, 0.7);
    
    final prevX2 = centerX + 20;
    _drawSimpleFigure(canvas, prevX2, runnerY + 4, paint, 0.4);
  }

  void _drawSimpleFigure(Canvas canvas, double x, double y, Paint paint, double scale) {
    final originalStroke = paint.strokeWidth;
    paint.strokeWidth = originalStroke * scale;
    
    // Simple stick figure shadow
    canvas.drawCircle(Offset(x, y - 30), 6 * scale, paint);
    canvas.drawLine(Offset(x, y - 24), Offset(x, y + 15), paint);
    canvas.drawLine(Offset(x, y - 12), Offset(x - 12, y - 5), paint);
    canvas.drawLine(Offset(x, y - 12), Offset(x + 12, y - 5), paint);
    canvas.drawLine(Offset(x, y + 15), Offset(x - 10, y + 30), paint);
    canvas.drawLine(Offset(x, y + 15), Offset(x + 10, y + 30), paint);
    
    paint.strokeWidth = originalStroke;
  }

  @override
  bool shouldRepaint(RunningFigurePainter oldDelegate) {
    return animationProgress != oldDelegate.animationProgress;
  }
}