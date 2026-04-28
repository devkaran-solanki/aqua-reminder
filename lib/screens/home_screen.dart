import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/circular_progress.dart';
import '../widgets/water_size_selector.dart';

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
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(provider),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hi, ${provider.profile.name.isNotEmpty ? provider.profile.name : 'Hydrator'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      // Streak badge
                      if (provider.currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.currentStreak}',
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Circular Progress
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
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

                  Color boxColor = AppColors.waterBlue;
                  IconData icon = Icons.notifications_active_outlined;
                  String title = 'Next Drink Suggested At';
                  String message = provider.nextDrinkingTime != null
                      ? DateFormat.jm().format(provider.nextDrinkingTime!)
                      : '';
                  bool showBox = provider.nextDrinkingTime != null;

                  if (provider.isGoalMet) {
                    showBox = true;
                    boxColor = Colors.green;
                    icon = Icons.emoji_events;
                    title = 'Goal Completed! 🎉';
                    message = 'Amazing job! You\'ve reached your daily hydration goal. Keep it up!';
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

                      // Check if we are currently BEFORE wake time, meaning it's late night / early morning
                      // Adjust sleepDt back for correct 'past bedtime' checking
                      if (now.isBefore(wakeDt) && sleepHour < wakeHour) {
                        sleepDt = sleepDt.subtract(const Duration(days: 1));
                      }

                      if (now.isAfter(sleepDt)) {
                        // It is actually after their sleep time
                        // Ensure we don't show this early morning *before* wake if sleep was before midnight
                        if (now.isBefore(wakeDt) && sleepHour > wakeHour) {
                           // Do nothing, normal next drink
                        } else {
                          showBox = true;
                          boxColor = Colors.indigoAccent;
                          icon = Icons.nightlight_round;
                          title = 'Past Bedtime 🌙';
                          message = 'You still have some left! Try your best, and start fresh tomorrow!';
                        }
                      } else if (provider.nextDrinkingTime == null && provider.todayIntake > 0) {
                        // It's not past sleep time, but nextDrinkingTime was pushed past sleep time
                        showBox = true;
                        boxColor = Colors.indigoAccent;
                        icon = Icons.nightlight_round;
                        title = 'Almost Bedtime 🌙';
                        message = 'Not enough time for another drink! Start fresh tomorrow!';
                      }
                    }
                  }

                  if (!showBox) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        // Reduced fixed height to make it more compact but identically sized.
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: boxColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: boxColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: boxColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: provider.isGoalMet || title.contains('Bedtime') ? 12.5 : 11,
                                      color: provider.isGoalMet || title.contains('Bedtime') ? boxColor : AppColors.textSecondary,
                                      fontWeight: provider.isGoalMet || title.contains('Bedtime') ? FontWeight.w700 : FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: provider.isGoalMet || title.contains('Bedtime') ? 11.5 : 12,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                      fontWeight: provider.isGoalMet || title.contains('Bedtime') ? FontWeight.w500 : FontWeight.w600,
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

              // Remaining info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.surfaceLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        _QuickStat(
                          icon: Icons.flag_outlined,
                          label: 'Remaining',
                          value: provider.formatAmountShort(
                            provider.remainingMl,
                          ),
                          color: AppColors.waterBlue,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: AppColors.surfaceLight,
                        ),
                        _QuickStat(
                          icon: Icons.format_list_numbered,
                          label: 'Glasses',
                          value: '${provider.todayEntries.length}',
                          color: AppColors.secondary,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: AppColors.surfaceLight,
                        ),
                        _QuickStat(
                          icon: Icons.local_fire_department,
                          label: 'Streak',
                          value: '${provider.currentStreak} days',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // Add Water Button
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
                    onSizeChanged: provider.setSelectedSize,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // Today's History
              if (provider.todayEntries.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Intake',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
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
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.undo,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Undo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
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
                        vertical: 3,
                      ),
                      child: Dismissible(
                        key: ValueKey(entry.timestamp.toIso8601String()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                        ),
                        onDismissed: (_) => provider.removeEntry(entry),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.surfaceLight.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.waterBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  color: AppColors.waterBlue,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.formatAmountShort(entry.amount),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'h:mm a',
                                    ).format(entry.timestamp),
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.chevron_left,
                                color: AppColors.textTertiary,
                                size: 18,
                              ),
                              const Text(
                                'swipe',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
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

              // Bottom spacer
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text(
          'Set Daily Goal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Recommended: 2000-3000 ml per day',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                suffixText: 'ml',
                suffixStyle: const TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.surfaceLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            // Quick presets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2000, 2500, 3000, 3500].map((goal) {
                return GestureDetector(
                  onTap: () => controller.text = goal.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${goal}ml',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          AnimatedFlipCounter(
            value:
                double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0,
            fractionDigits: 0,
            suffix: value.replaceAll(RegExp(r'[0-9.]'), ''),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            textStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
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
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.water_drop,
                color: AppColors.background,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Drink ${widget.sizeMl} ${context.read<WaterProvider>().unitLabel}',
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
