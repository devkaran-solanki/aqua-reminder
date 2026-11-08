import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import '../utils/constants.dart';

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
    final isGoalMet = widget.progress >= 1.0;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Track & Progress Arc
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  progress: _animation.value,
                  strokeWidth: 15,
                ),
              );
            },
          ),
          // Center content (Restores exact vertical baseline from when drop was present)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preserves the exact 30px offset from the previous 26px drop + 4px gap
              const SizedBox(height: 30),

              // Current Amount Metric Readout
              AnimatedFlipCounter(
                value: double.tryParse(
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
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.0,
                  height: 1.1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),

              // Goal Subtitle
              Text(
                'of ${widget.displayGoal}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
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
                  color: isGoalMet
                      ? AppColors.cyanGlow
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isGoalMet
                        ? AppColors.borderActive
                        : AppColors.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  isGoalMet
                      ? '✓ Goal Met!'
                      : '${(widget.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isGoalMet
                        ? AppColors.cyanBright
                        : AppColors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

  _CircularProgressPainter({required this.progress, this.strokeWidth = 15});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track (subtle neutral dark obsidian track)
    final trackPaint = Paint()
      ..color = const Color(0xFF141414)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc (Natural Cyan/Aqua Water Gradient)
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

      final gradient = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: const [
          Color(0xFF00FFE0), // Radiant Mint Aqua (luminous origin at 12 o'clock)
          Color(0xFF00F2FE), // Electric Cyan
          Color(0xFF00D2FF), // Radiant Sky Aqua
          Color(0xFF00A3E0), // Deep Marine Aqua (natural depth at bottom)
          Color(0xFF00D2FF), // Radiant Sky Aqua
          Color(0xFF00F2FE), // Electric Cyan
          Color(0xFF00FFE0), // Radiant Mint Aqua
        ],
        stops: const [0.0, 0.18, 0.38, 0.55, 0.72, 0.88, 1.0],
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
