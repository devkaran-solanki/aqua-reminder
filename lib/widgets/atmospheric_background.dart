import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Reusable atmospheric background container applying the Fortify
/// Deep Obsidian canvas and dual ambient emerald/forest lighting orbs.
class AtmosphericBackground extends StatelessWidget {
  final Widget child;

  const AtmosphericBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // 0. Deep obsidian base canvas
        const Positioned.fill(
          child: ColoredBox(color: AppColors.background),
        ),

        // 1. Top-Center Emerald Radial Orb (Simulates top studio downlight)
        Positioned(
          top: -size.width * 0.45,
          left: -size.width * 0.15,
          right: -size.width * 0.15,
          height: size.width * 1.35,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.topCenterAmbientOrb,
              ),
            ),
          ),
        ),

        // 2. Bottom-Left Counter Glow Orb (Balances the viewport)
        Positioned(
          bottom: -size.width * 0.35,
          left: -size.width * 0.35,
          width: size.width * 1.1,
          height: size.width * 1.1,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.bottomLeftAmbientOrb,
              ),
            ),
          ),
        ),

        // 3. Foreground content
        child,
      ],
    );
  }
}

