import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

import 'package:animated_flip_counter/animated_flip_counter.dart';

class CircularWaterProgress extends StatefulWidget {
  final double progress;
  final int currentMl;
  final int goalMl;
  final String displayCurrent;
  final String displayGoal;
  final double size;

  const CircularWaterProgress({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    required this.displayCurrent,
    required this.displayGoal,
    this.size = 260,
  });

  @override
  State<CircularWaterProgress> createState() => _CircularWaterProgressState();
}

class _CircularWaterProgressState extends State<CircularWaterProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularWaterProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(begin: _previousProgress, end: widget.progress)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller
        ..duration = const Duration(milliseconds: 800)
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  progress: _animation.value,
                  strokeWidth: 14,
                ),
              );
            },
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Water drop icon
              Icon(
                Icons.water_drop,
                color: widget.progress >= 1.0
                    ? AppColors.success
                    : AppColors.waterBlue.withValues(alpha: 0.6),
                size: 28,
              ),
              const SizedBox(height: 4),
              // Current amount
              AnimatedFlipCounter(
                value:
                    double.tryParse(
                      widget.displayCurrent.replaceAll(
                        RegExp(r'[^0-9.]'),
                        '',
                      ),
                    ) ??
                    0,
                fractionDigits: 0,
                suffix: widget.displayCurrent.replaceAll(
                  RegExp(r'[0-9.]'),
                  '',
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                textStyle: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              Text(
                'of ${widget.displayGoal}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              // Percentage
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.progress >= 1.0
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  widget.progress >= 1.0
                      ? '✓ Goal Met!'
                      : '${(widget.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.progress >= 1.0
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _CircularProgressPainter({required this.progress, this.strokeWidth = 14});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.surfaceLight.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * progress;

      // Create gradient
      final gradient = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: const [
          AppColors.primary,
          AppColors.waterBlue,
          AppColors.secondary,
          AppColors.primary,
        ],
        stops: const [0.0, 0.33, 0.66, 1.0],
        transform: const GradientRotation(-pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
