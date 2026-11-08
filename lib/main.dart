import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/water_provider.dart';
import 'screens/home_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';
import 'widgets/atmospheric_background.dart';
import 'widgets/fade_indexed_stack.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.canvasFrame,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const AqueaApp());
}

typedef AquaReminderApp = AqueaApp;

class AqueaApp extends StatelessWidget {
  const AqueaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WaterProvider()..loadData(),
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          canvasColor: AppColors.background,
          cardColor: AppColors.card,
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.card),
          dividerColor: AppColors.divider,
          textTheme: GoogleFonts.montserratTextTheme(
            ThemeData.dark().textTheme,
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppColors.emeraldPrimary,
            secondary: AppColors.emeraldBright,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
            error: AppColors.failure,
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        home: const _AppRouter(),
      ),
    );
  }
}

/// Routes between onboarding and main app based on profile state
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        if (!provider.isLoaded) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.emeraldBright,
                strokeWidth: 3,
              ),
            ),
          );
        }

        if (!provider.isOnboardingComplete) {
          return const OnboardingScreen();
        }

        return const MainShell();
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AtmosphericBackground(
        child: Stack(
          children: [
            // Full-screen scrollable views that flow seamlessly under the floating bar
            Positioned.fill(
              child: FadeIndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  ReportsScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
            // Floating Glassmorphic Nav Capsule
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFloatingNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double bottomMargin = bottomInset > 0 ? bottomInset + 8 : 20.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                // Deep obsidian ambient drop shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    // Multi-stop frosted obsidian glass gradient
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cardElevated.withValues(alpha: 0.85),
                        AppColors.card.withValues(alpha: 0.78),
                        AppColors.background.withValues(alpha: 0.90),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                    // Specular titanium hairline rim
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.0,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth / 3;

                      return Stack(
                        children: [
                              // Sliding Inverted White Pill Indicator (Original Gliding Animation)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                left: _currentIndex * itemWidth,
                                top: 0,
                                bottom: 0,
                                width: itemWidth,
                                child: Center(
                                  child: Container(
                                    width: itemWidth - 12,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          blurRadius: 14,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Proportional Navigation Items
                              Row(
                                children: [
                                  _buildNavItem(
                                    index: 0,
                                    customIconBuilder: (color, size) => _AquaDropD1(
                                      color: color,
                                      size: size,
                                    ),
                                    label: 'Hydrate',
                                    width: itemWidth,
                                  ),
                                  _buildNavItem(
                                    index: 1,
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Reports',
                                    width: itemWidth,
                                  ),
                                  _buildNavItem(
                                    index: 2,
                                    icon: Icons.person_rounded,
                                    label: 'Profile',
                                    width: itemWidth,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildNavItem({
    required int index,
    IconData? icon,
    Widget Function(Color color, double size)? customIconBuilder,
    required String label,
    required double width,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateTo(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 66,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: isActive ? Colors.black : AppColors.textSecondary,
                ),
                duration: const Duration(milliseconds: 220),
                builder: (context, color, _) {
                  final activeColor = color ?? AppColors.textSecondary;
                  if (customIconBuilder != null) {
                    return customIconBuilder(activeColor, 20);
                  }
                  return Icon(
                    icon,
                    color: activeColor,
                    size: 20,
                  );
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }
}

/// Option D1: Apple SF style organic solid water drop.
class _AquaDropD1 extends StatelessWidget {
  final double size;
  final Color color;

  const _AquaDropD1({
    this.size = 20.0,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AquaDropD1Painter(color: color),
    );
  }
}

class _AquaDropD1Painter extends CustomPainter {
  final Color color;

  _AquaDropD1Painter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final path = Path();
    // SVG Option D1: M12 2.5 C11.5 3.2 5.5 11.2 5.5 15.5 C5.5 19.1 8.4 22 12 22 C15.6 22 18.5 19.1 18.5 15.5 C18.5 11.2 12.5 3.2 12 2.5 Z
    path.moveTo(12.0 * s, 2.5 * s);
    path.cubicTo(11.5 * s, 3.2 * s, 5.5 * s, 11.2 * s, 5.5 * s, 15.5 * s);
    path.cubicTo(5.5 * s, 19.1 * s, 8.4 * s, 22.0 * s, 12.0 * s, 22.0 * s);
    path.cubicTo(15.6 * s, 22.0 * s, 18.5 * s, 19.1 * s, 18.5 * s, 15.5 * s);
    path.cubicTo(18.5 * s, 11.2 * s, 12.5 * s, 3.2 * s, 12.0 * s, 2.5 * s);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AquaDropD1Painter oldDelegate) {
    return oldDelegate.color != color;
  }
}
