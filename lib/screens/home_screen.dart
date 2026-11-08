import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/circular_progress.dart';
import '../widgets/water_size_selector.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top App Bar / Profile & Streak Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Squircle App Logo Housing
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: AppColors.borderSubtle,
                                width: 1.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/app_icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(provider),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                provider.profile.name.isNotEmpty
                                    ? provider.profile.name
                                    : 'Hydrator',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Streak badge (Matches 🔥 streak pill in screenshot)
                      if (provider.currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 6),
                              Text(
                                '${provider.currentStreak}d streak',
                                style: const TextStyle(
                                  color: AppColors.warmup,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Circular Progress Hero Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _showGoalDialog(context, provider),
                      child: CircularWaterProgress(
                        progress: provider.todayProgress,
                        currentMl: provider.todayIntake,
                        goalMl: provider.dailyGoalMl,
                        displayCurrent: provider.formatAmountShort(
                          provider.todayIntake,
                        ),
                        displayGoal: provider.formatAmountShort(
                          provider.dailyGoalMl,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Suggestion Box
              Builder(
                builder: (context) {
                  final now = DateTime.now();

                  Color accentColor = AppColors.emeraldBright;
                  IconData icon = Icons.notifications_active_rounded;
                  String title = 'NEXT DRINK SUGGESTED AT';
                  String message = provider.nextDrinkingTime != null
                      ? DateFormat.jm().format(provider.nextDrinkingTime!)
                      : '';
                  bool showBox = provider.nextDrinkingTime != null;

                  if (provider.isGoalMet) {
                    showBox = true;
                    accentColor = AppColors.emeraldBright;
                    icon = Icons.emoji_events_rounded;
                    title = 'GOAL COMPLETED';
                    message = 'Daily target reached! Keep up the optimal hydration!';
                  } else {
                    final sleepParts = provider.profile.sleepTime.split(':');
                    final wakeParts = provider.profile.wakeTime.split(':');
                    if (sleepParts.length == 2 && wakeParts.length == 2) {
                      int wakeHour = int.tryParse(wakeParts[0]) ?? 7;
                      int wakeMinute = int.tryParse(wakeParts[1]) ?? 0;
                      int sleepHour = int.tryParse(sleepParts[0]) ?? 23;
                      int sleepMinute = int.tryParse(sleepParts[1]) ?? 0;

                      DateTime wakeDt = DateTime(now.year, now.month, now.day, wakeHour, wakeMinute);
                      DateTime sleepDt = DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
                      if (sleepDt.isBefore(wakeDt)) {
                        sleepDt = sleepDt.add(const Duration(days: 1));
                      }

                      if (now.isBefore(wakeDt) && sleepHour < wakeHour) {
                        sleepDt = sleepDt.subtract(const Duration(days: 1));
                      }

                      if (now.isAfter(sleepDt)) {
                        if (now.isBefore(wakeDt) && sleepHour > wakeHour) {
                          // normal
                        } else {
                          showBox = true;
                          accentColor = AppColors.warmup;
                          icon = Icons.nightlight_round;
                          title = 'PAST BEDTIME 🌙';
                          message = 'Rest well tonight and start hydrated tomorrow!';
                        }
                      } else if (provider.nextDrinkingTime == null && provider.todayIntake > 0) {
                        showBox = true;
                        accentColor = AppColors.warmup;
                        icon = Icons.nightlight_round;
                        title = 'ALMOST BEDTIME 🌙';
                        message = 'Wind down and prepare for a fresh start tomorrow.';
                      }
                    }
                  }

                  if (!showBox) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.cardElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                  width: 1.0,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Quick Stats Card (Layered elevation via #101512 with 10% white hairline)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        _QuickStat(
                          icon: Icons.flag_rounded,
                          label: 'REMAINING',
                          value: provider.formatAmountShort(
                            provider.remainingMl,
                          ),
                          accentColor: AppColors.cyanBright,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: AppColors.divider,
                        ),
                        _QuickStat(
                          iconWidget: SvgPicture.asset(
                            'assets/images/glass.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColors.cyanBright,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: 'GLASSES',
                          value: '${provider.todayEntries.length}',
                          accentColor: AppColors.cyanBright,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: AppColors.divider,
                        ),
                        _QuickStat(
                          icon: Icons.history_rounded,
                          label: 'LAST SIP',
                          value: provider.todayEntries.isNotEmpty
                              ? DateFormat('h:mm a').format(
                                  provider.todayEntries.first.timestamp,
                                )
                              : '—',
                          accentColor: AppColors.cyanBright,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Primary Hero Call-To-Action Button ("Drink X ml")
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AddWaterButton(
                    sizeMl: provider.selectedSize,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      provider.addWater();
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Water Size Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: WaterSizeSelector(
                    selectedSize: provider.selectedSize,
                    customSize: provider.lastCustomSize,
                    onSizeChanged: provider.setSelectedSize,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // Today's History Section
              if (provider.todayEntries.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TODAY'S INTAKE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            provider.undoLastEntry();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              border: Border.all(
                                color: AppColors.borderSubtle,
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.undo_rounded,
                                  size: 13,
                                  color: AppColors.failure,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Undo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.failure,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = provider.todayEntries[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Dismissible(
                        key: ValueKey(entry.timestamp.toIso8601String()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.failure.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.failure,
                          ),
                        ),
                        onDismissed: (_) => provider.removeEntry(entry),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.cardElevated,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                    width: 1.0,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.water_drop_rounded,
                                    color: AppColors.cyanBright,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.formatAmountShort(entry.amount),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'h:mm a',
                                    ).format(entry.timestamp),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.chevron_left_rounded,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              const Text(
                                'swipe',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: provider.todayEntries.length),
                ),
              ],

              // Bottom spacer for floating capsule navigation bar
              const SliverToBoxAdapter(child: SizedBox(height: 124)),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting(WaterProvider provider) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  void _showGoalDialog(BuildContext context, WaterProvider provider) {
    final controller = TextEditingController(
      text: provider.dailyGoalMl.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Daily Target',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended range: 2000 - 3000 ml per day',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                suffixText: 'ml',
                suffixStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: AppColors.cardLight,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.emeraldPrimary, width: 1.5),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 14),
            // Quick preset pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [2000, 2500, 3000, 3500].map((goal) {
                return GestureDetector(
                  onTap: () => controller.text = goal.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '${goal}ml',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 500 && value <= 10000) {
                provider.setDailyGoal(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.emeraldBright,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final String value;
  final Color accentColor;

  const _QuickStat({
    this.icon,
    this.iconWidget,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final numericPart =
        double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    final isPlainCounter =
        numericPart != null && !value.contains(':') && !value.contains('Done');

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.cardElevated,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Center(
              child: iconWidget ??
                  Icon(
                    icon,
                    color: accentColor,
                    size: 16,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          if (isPlainCounter)
            AnimatedFlipCounter(
              value: numericPart,
              fractionDigits: 0,
              suffix: value.replaceAll(RegExp(r'[0-9.]'), ''),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              textStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: -0.3,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: -0.3,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddWaterButton extends StatefulWidget {
  final int sizeMl;
  final VoidCallback onPressed;

  const _AddWaterButton({required this.sizeMl, required this.onPressed});

  @override
  State<_AddWaterButton> createState() => _AddWaterButtonState();
}

class _AddWaterButtonState extends State<_AddWaterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            // Primary Hero Call-To-Action Recipe (Resonating with new Logo)
            gradient: AppColors.heroCtaGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.heroCtaShadow,
          ),
          child: Center(
            child: Text(
              'Drink ${widget.sizeMl} ${context.read<WaterProvider>().unitLabel}',
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
