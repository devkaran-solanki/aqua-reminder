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

import 'package:aqua_reminder/widgets/fade_indexed_stack.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const AquaReminderApp());
}

class AquaReminderApp extends StatelessWidget {
  const AquaReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WaterProvider()..loadData(),
      child: MaterialApp(
        title: 'Aqua Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
          ),
          splashFactory: InkSparkle.splashFactory,
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
                color: AppColors.primary,
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
      body: FadeIndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          ReportsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70, // Fixed height for the bottom nav
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceLight.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 3;
              
              return Stack(
                children: [
                  // Sliding indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: _currentIndex * itemWidth,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: itemWidth,
                      child: Center(
                        child: Container(
                          width: itemWidth * 0.7, // Width of the pill
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Navigation Items
                  Row(
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.water_drop_outlined,
                        activeIcon: Icons.water_drop,
                        label: 'Home',
                        width: itemWidth,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.bar_chart_outlined,
                        activeIcon: Icons.bar_chart,
                        label: 'Reports',
                        width: itemWidth,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                        width: itemWidth,
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required double width,
  }) {
    final bool isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _navigateTo(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                  size: 22,
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
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  void _navigateTo(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }
}

