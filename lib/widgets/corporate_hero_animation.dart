import 'package:flutter/material.dart';
import 'dart:math' as math;

class CorporateHeroAnimation extends StatefulWidget {
  final Widget child;

  const CorporateHeroAnimation({
    super.key,
    required this.child,
  });

  @override
  State<CorporateHeroAnimation> createState() => _CorporateHeroAnimationState();
}

class _CorporateHeroAnimationState extends State<CorporateHeroAnimation>
    with TickerProviderStateMixin {
  late AnimationController _runnerController;
  late AnimationController _counterController;
  late AnimationController _backgroundController;
  
  late Animation<double> _runnerAnimation;
  late Animation<int> _stepCounterAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    // Runner silhouette animation (跑步剪影動畫)
    _runnerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Step counter animation (步數統計動畫)
    _counterController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Background elements (背景元素動畫)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _runnerAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _runnerController,
      curve: Curves.easeInOut,
    ));

    _stepCounterAnimation = IntTween(
      begin: 0,
      end: 10000,
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _backgroundController.repeat();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _runnerController.repeat();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _counterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _runnerController.dispose();
    _counterController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated background elements
        AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: CorporateBackgroundPainter(
                progress: _backgroundAnimation.value,
              ),
            );
          },
        ),
        
        // Running silhouettes
        AnimatedBuilder(
          animation: _runnerAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: RunningSilhouettePainter(
                progress: _runnerAnimation.value,
              ),
            );
          },
        ),
        
        // Step counter display
        Positioned(
          top: 60,
          right: 30,
          child: AnimatedBuilder(
            animation: _stepCounterAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_stepCounterAnimation.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Achievement badges
        Positioned(
          top: 120,
          right: 30,
          child: AnimatedBuilder(
            animation: _counterController,
            builder: (context, child) {
              final opacity = _counterController.value;
              return Opacity(
                opacity: opacity,
                child: Column(
                  children: [
                    _buildAchievementBadge('🏃', 'Active'),
                    const SizedBox(height: 8),
                    _buildAchievementBadge('💪', 'Strong'),
                    const SizedBox(height: 8),
                    _buildAchievementBadge('🎯', 'Goal'),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Content overlay
        widget.child,
      ],
    );
  }

  Widget _buildAchievementBadge(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CorporateBackgroundPainter extends CustomPainter {
  final double progress;

  CorporateBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw corporate grid pattern
    _drawGrid(canvas, size, paint);
    
    // Draw floating geometric shapes
    _drawGeometricShapes(canvas, size, paint);
    
    // Draw progress arcs
    _drawProgressArcs(canvas, size, paint);
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withOpacity(0.08);
    paint.strokeWidth = 1;

    final gridSize = 40.0;
    final offsetX = (progress * gridSize) % gridSize;
    final offsetY = (progress * gridSize * 0.7) % gridSize;

    // Vertical lines
    for (double x = -gridSize + offsetX; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = -gridSize + offsetY; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawGeometricShapes(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    final shapes = [
      {'x': size.width * 0.15, 'y': size.height * 0.2, 'size': 30.0, 'rotation': progress * 2},
      {'x': size.width * 0.85, 'y': size.height * 0.15, 'size': 25.0, 'rotation': -progress * 1.5},
      {'x': size.width * 0.1, 'y': size.height * 0.8, 'size': 35.0, 'rotation': progress * 1.2},
    ];

    for (var shape in shapes) {
      canvas.save();
      canvas.translate(shape['x'] as double, shape['y'] as double);
      canvas.rotate(shape['rotation'] as double);
      
      paint.color = Colors.white.withOpacity(0.1);
      
      // Draw rotating hexagon
      final path = Path();
      final size = shape['size'] as double;
      for (int i = 0; i < 6; i++) {
        final angle = (i * math.pi * 2 / 6);
        final x = math.cos(angle) * size;
        final y = math.sin(angle) * size;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      
      canvas.restore();
    }
  }

  void _drawProgressArcs(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.9, size.height * 0.85);
    final radius = 25.0;

    // Background arc
    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    paint.color = Colors.white.withOpacity(0.3);
    final sweepAngle = progress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CorporateBackgroundPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class RunningSilhouettePainter extends CustomPainter {
  final double progress;

  RunningSilhouettePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw multiple running silhouettes at different depths
    _drawRunningSilhouette(canvas, size.width * 0.7, size.height * 0.6, 0.8, paint);
    _drawRunningSilhouette(canvas, size.width * 0.75, size.height * 0.65, 0.6, paint);
    _drawRunningSilhouette(canvas, size.width * 0.8, size.height * 0.7, 0.4, paint);
  }

  void _drawRunningSilhouette(Canvas canvas, double x, double y, double opacity, Paint paint) {
    paint.color = Colors.white.withOpacity(0.05 * opacity);

    // Running cycle animation
    final cycle = progress * 4;
    final legPhase = math.sin(cycle * math.pi * 2);
    final armPhase = math.sin((cycle + 0.5) * math.pi * 2);
    final bounce = (math.sin(cycle * math.pi * 2)).abs() * 3;

    final runnerY = y - bounce;

    // Create runner silhouette path
    final path = Path();
    
    // Head
    path.addOval(Rect.fromCircle(center: Offset(x, runnerY - 25), radius: 6));
    
    // Body (simplified silhouette)
    path.moveTo(x, runnerY - 19);
    path.lineTo(x, runnerY + 15);
    
    // Arms
    path.moveTo(x, runnerY - 5);
    path.lineTo(x - 12 + armPhase * 8, runnerY + armPhase * 6);
    path.moveTo(x, runnerY - 5);
    path.lineTo(x + 12 - armPhase * 8, runnerY - armPhase * 6);
    
    // Legs
    path.moveTo(x, runnerY + 15);
    path.lineTo(x - 8 + legPhase * 12, runnerY + 30 + legPhase.abs() * 8);
    path.moveTo(x, runnerY + 15);
    path.lineTo(x + 8 - legPhase * 12, runnerY + 30 + (-legPhase).abs() * 8);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RunningSilhouettePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}