import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/water_entry.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/intake_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Day', 'Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text(
              'Reports',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Tab Bar (Inverted White Pill from Fortify Spec Section 3.C)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: AppColors.whitePillShadow,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tab Pages
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReportsTabView(tabIndex: 0, tabController: _tabController),
                _ReportsTabView(tabIndex: 1, tabController: _tabController),
                _ReportsTabView(tabIndex: 2, tabController: _tabController),
                _ReportsTabView(tabIndex: 3, tabController: _tabController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsTabView extends StatefulWidget {
  final int tabIndex;
  final TabController tabController;
  const _ReportsTabView({required this.tabIndex, required this.tabController});

  @override
  State<_ReportsTabView> createState() => _ReportsTabViewState();
}

class _ReportsTabViewState extends State<_ReportsTabView>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();

  TabController get _tabController => widget.tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDateNavigation(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // StatsCards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsCards(provider),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // Chart Card (Fortify #101512 with 10% white hairline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 260,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getChartTitle().toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _buildChart(provider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // Detailed Breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDetailedBreakdown(provider),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 124)),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards(WaterProvider provider) {
    final stats = _getStats(provider);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: stats.map((stat) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                    child: Icon(stat.icon, color: stat.color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      stat.label.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stat.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1.15,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<_StatData> _getStats(WaterProvider provider) {
    switch (widget.tabIndex) {
      case 0: // Day
        final dayIntake = provider.getIntakeForDate(_selectedDate);
        final dayEntries = _getEntriesForDate(provider, _selectedDate);
        final goal = provider.dailyGoalMl;
        final dayProgress = goal > 0 ? (dayIntake / goal).clamp(0.0, 1.0) : 0.0;
        final isGoalMet = dayIntake >= goal;

        return [
          _StatData(
            icon: Icons.water_drop_rounded,
            label: 'Total Intake',
            value: _formatMl(dayIntake),
            color: AppColors.emeraldBright,
          ),
          _StatData(
            icon: Icons.flag_rounded,
            label: 'Goal',
            value: _formatMl(goal),
            color: AppColors.emeraldPrimary,
          ),
          _StatData(
            icon: Icons.format_list_numbered_rounded,
            label: 'Entries',
            value: '${dayEntries.length}',
            color: AppColors.textPrimary,
          ),
          _StatData(
            icon: Icons.percent_rounded,
            label: 'Completion',
            value: '${(dayProgress * 100).toInt()}%',
            color: isGoalMet
                ? AppColors.emeraldBright
                : AppColors.warmup,
          ),
        ];
      case 1: // Week
        final date = _selectedDate;
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final dailyTotals = provider.getDailyTotals(weekStart, weekEnd);
        final totalWeek = dailyTotals.values.fold<int>(0, (a, b) => a + b);
        final daysWithData = dailyTotals.values.where((v) => v > 0).length;
        final avg = daysWithData > 0 ? totalWeek ~/ daysWithData : 0;
        final goalDays = dailyTotals.values
            .where((v) => v >= provider.dailyGoalMl)
            .length;

        final now = DateTime.now();
        final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final isThisWeek = weekStart.year == currentWeekStart.year && 
                           weekStart.month == currentWeekStart.month && 
                           weekStart.day == currentWeekStart.day;
        final goalMax = isThisWeek ? now.weekday : 7;

        return [
          _StatData(
            icon: Icons.water_drop_rounded,
            label: 'Total Intake',
            value: _formatMl(totalWeek),
            color: AppColors.emeraldBright,
          ),
          _StatData(
            icon: Icons.show_chart_rounded,
            label: 'Daily Average',
            value: _formatMl(avg),
            color: AppColors.emeraldPrimary,
          ),
          _StatData(
            icon: Icons.emoji_events_rounded,
            label: 'Goals Met',
            value: '$goalDays / $goalMax',
            color: AppColors.warmup,
          ),
          _StatData(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${provider.currentStreak} days',
            color: AppColors.warmup,
          ),
        ];
      case 2: // Month
        final date = _selectedDate;
        final monthStart = DateTime(date.year, date.month, 1);
        final monthEnd = DateTime(date.year, date.month + 1, 0);
        final dailyTotals = provider.getDailyTotals(monthStart, monthEnd);
        final totalMonth = dailyTotals.values.fold<int>(0, (a, b) => a + b);
        final daysWithData = dailyTotals.values.where((v) => v > 0).length;
        final avg = daysWithData > 0 ? totalMonth ~/ daysWithData : 0;
        
        int bestDayIntake = 0;
        for (var v in dailyTotals.values) {
          if (v > bestDayIntake) bestDayIntake = v;
        }

        return [
          _StatData(
            icon: Icons.water_drop_rounded,
            label: 'Total Intake',
            value: _formatMl(totalMonth),
            color: AppColors.emeraldBright,
          ),
          _StatData(
            icon: Icons.show_chart_rounded,
            label: 'Daily Average',
            value: _formatMl(avg),
            color: AppColors.emeraldPrimary,
          ),
          _StatData(
            icon: Icons.star_rounded,
            label: 'Best Day',
            value: _formatMl(bestDayIntake),
            color: AppColors.warmup,
          ),
          _StatData(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${provider.currentStreak} days',
            color: AppColors.warmup,
          ),
        ];
      case 3: // Year
        final date = _selectedDate;
        final monthlyTotals = provider.getMonthlyTotals(date.year);
        final totalYear = monthlyTotals.values.fold<int>(0, (a, b) => a + b);
        final monthsWithData = monthlyTotals.values.where((v) => v > 0).length;
        final avgMonthly = monthsWithData > 0 ? totalYear ~/ monthsWithData : 0;
        
        int bestMonthIntake = 0;
        for (var v in monthlyTotals.values) {
          if (v > bestMonthIntake) bestMonthIntake = v;
        }

        return [
          _StatData(
            icon: Icons.water_drop_rounded,
            label: 'Total Intake',
            value: _formatLiters(totalYear),
            color: AppColors.emeraldBright,
          ),
          _StatData(
            icon: Icons.calendar_month_rounded,
            label: 'Monthly Avg',
            value: _formatLiters(avgMonthly),
            color: AppColors.emeraldPrimary,
          ),
          _StatData(
            icon: Icons.star_rounded,
            label: 'Best Month',
            value: _formatLiters(bestMonthIntake),
            color: AppColors.warmup,
          ),
          _StatData(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${provider.currentStreak} days',
            color: AppColors.warmup,
          ),
        ];
      default:
        return [];
    }
  }



  Widget _buildChart(WaterProvider provider) {
    if (widget.tabIndex == 0) {
      final hourly = provider.getHourlyTotals(_selectedDate);
      final Map<String, double> chartData = {};
      for (int i = 0; i < 24; i += 3) {
        double sum = 0;
        for (int j = 0; j < 3; j++) {
          sum += hourly[i + j] ?? 0;
        }
        final hourFormat = DateFormat('h a').format(DateTime(2020, 1, 1, i));
        chartData[hourFormat] = sum;
      }
      return IntakeBarChart(data: chartData, goalLine: provider.dailyGoalMl / 8);
    } else if (widget.tabIndex == 1) {
      final start = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      final daily = provider.getDailyTotals(start, end);
      final Map<String, double> chartData = {};
      daily.forEach((date, value) {
        chartData[DateFormat('E').format(date)] = value.toDouble();
      });
      return IntakeBarChart(data: chartData, goalLine: provider.dailyGoalMl.toDouble());
    } else if (widget.tabIndex == 2) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      final daily = provider.getDailyTotals(start, end);
      final Map<String, double> chartData = {};
      daily.forEach((date, value) {
        if (date.day % 5 == 1 || date.day == end.day) {
          chartData[date.day.toString()] = value.toDouble();
        } else {
          chartData['_${date.day}'] = value.toDouble(); // Hidden labels
        }
      });
      return IntakeBarChart(data: chartData, goalLine: provider.dailyGoalMl.toDouble());
    } else {
      final monthly = provider.getMonthlyTotals(_selectedDate.year);
      final Map<String, double> chartData = {};
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (int i = 1; i <= 12; i++) {
        chartData[monthNames[i - 1]] = (monthly[i] ?? 0).toDouble();
      }
      return IntakeBarChart(
          data: chartData,
          goalLine: (provider.dailyGoalMl * 30).toDouble(),
        );
    }
  }

  Widget _buildDetailedBreakdown(WaterProvider provider) {
    if (widget.tabIndex == 0) {
      // Day view: show timeline of entries
      final entries = _getEntriesForDate(provider, _selectedDate);
      if (entries.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  size: 26,
                  color: AppColors.emeraldBright,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "NO HYDRATION DATA",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isToday(_selectedDate) ? "Start drinking to populate your stats!" : "No activities recorded for this date.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TIMELINE',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            ...entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.emeraldBright,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('h:mm a').format(entry.timestamp),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.amount} ml',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      );
    }

    // Week/Month/Year: show daily breakdown list
    if (widget.tabIndex == 1) {
      final date = _selectedDate;
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final dailyTotals = provider.getDailyTotals(weekStart, weekEnd);
      
      final now = DateTime.now();
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final isThisWeek = weekStart.year == currentWeekStart.year && 
                         weekStart.month == currentWeekStart.month && 
                         weekStart.day == currentWeekStart.day;
      
      final title = isThisWeek
          ? 'THIS WEEK'
          : '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}'.toUpperCase();
          
      return _buildDailyBreakdownList(title, dailyTotals, provider.dailyGoalMl);
    }

    if (widget.tabIndex == 2) {
      final date = _selectedDate;
      final monthStart = DateTime(date.year, date.month, 1);
      final monthEnd = DateTime(date.year, date.month + 1, 0);
      final dailyTotals = provider.getDailyTotals(monthStart, monthEnd);
      
      final now = DateTime.now();
      final isThisMonth = date.year == now.year && date.month == now.month;
      return _buildDailyBreakdownList(
          (isThisMonth ? 'THIS MONTH' : DateFormat('MMMM yyyy').format(date)).toUpperCase(), 
          dailyTotals, 
          provider.dailyGoalMl);
    }

    // Year view
    final date = _selectedDate;
    final now = DateTime.now();
    final isThisYear = date.year == now.year;
    final isPastYear = date.year < now.year;
    final monthlyTotals = provider.getMonthlyTotals(date.year);
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (isThisYear ? 'THIS YEAR BREAKDOWN' : '${date.year} MONTHLY BREAKDOWN').toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(12, (i) {
            final month = i + 1;
            final total = monthlyTotals[month] ?? 0;
            final monthGoal = provider.dailyGoalMl * 30;
            final progress = monthGoal > 0
                ? (total / monthGoal).clamp(0.0, 1.0)
                : 0.0;
            
            final isMonthValid = isPastYear || (isThisYear && month <= now.month);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                   SizedBox(
                    width: 60,
                    child: Text(
                      monthNames[i].substring(0, 3),
                      style: TextStyle(
                        color: isMonthValid
                            ? AppColors.textSecondary
                            : AppColors.textMuted.withValues(alpha: 0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.cardLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          total >= monthGoal && isMonthValid
                              ? AppColors.emeraldBright
                              : (isMonthValid ? AppColors.emeraldPrimary.withValues(alpha: 0.6) : AppColors.cardHover),
                        ),
                        minHeight: 7,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 55,
                    child: Text(
                      _formatLiters(total),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: isMonthValid
                            ? AppColors.textPrimary
                            : AppColors.textMuted.withValues(alpha: 0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdownList(
      String title, Map<DateTime, int> dailyTotals, int goal) {
    final sortedEntries = dailyTotals.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...sortedEntries.map((entry) {
            final isToday = _isToday(entry.key);
            final metGoal = entry.value >= goal;
            final progress =
                goal > 0 ? (entry.value / goal).clamp(0.0, 1.0) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: Text(
                      isToday
                          ? 'Today'
                          : DateFormat('E d').format(entry.key),
                      style: TextStyle(
                        color: isToday
                            ? AppColors.emeraldBright
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            isToday ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.cardLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          metGoal ? AppColors.emeraldBright : AppColors.cardHover,
                        ),
                        minHeight: 7,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text(
                      _formatMl(entry.value),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: metGoal
                            ? AppColors.emeraldBright
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (metGoal)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.emeraldBright,
                        size: 15,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getChartTitle() {
    switch (_tabController.index) {
      case 0:
        return 'Hourly Intake';
      case 1:
        return 'Daily Intake';
      case 2:
        return 'Daily Intake';
      case 3:
        return 'Monthly Intake';
      default:
        return '';
    }
  }

  String _formatMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(2)}L';
    }
    return '${ml}ml';
  }

  String _formatLiters(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(2)}L';
    }
    return '${ml}ml';
  }

  List<WaterEntry> _getEntriesForDate(WaterProvider provider, DateTime date) {
    return provider.entries.where((e) {
      return e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _previousPeriod() {
    setState(() {
      if (_tabController.index == 0) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else if (_tabController.index == 1) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else if (_tabController.index == 2) {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
      } else if (_tabController.index == 3) {
        _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month, _selectedDate.day);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_tabController.index == 0) {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      } else if (_tabController.index == 1) {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      } else if (_tabController.index == 2) {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
      } else if (_tabController.index == 3) {
        _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month, _selectedDate.day);
      }
    });
  }

  bool _canGoNext() {
    final now = DateTime.now();
    if (_tabController.index == 0) {
      return !_isToday(_selectedDate);
    } else if (_tabController.index == 1) {
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final selectedWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      return selectedWeekStart.isBefore(DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day));
    } else if (_tabController.index == 2) {
      return _selectedDate.year < now.year || (_selectedDate.year == now.year && _selectedDate.month < now.month);
    } else if (_tabController.index == 3) {
      return _selectedDate.year < now.year;
    }
    return false;
  }

  String _getPeriodText() {
    final now = DateTime.now();
    if (_tabController.index == 0) {
      return _isToday(_selectedDate) ? 'Today' : DateFormat('MMM d, yyyy').format(_selectedDate);
    } else if (_tabController.index == 1) {
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final selectedWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      if (selectedWeekStart.year == currentWeekStart.year && 
          selectedWeekStart.month == currentWeekStart.month && 
          selectedWeekStart.day == currentWeekStart.day) {
        return 'This Week';
      }
      final end = selectedWeekStart.add(const Duration(days: 6));
      if (selectedWeekStart.month == end.month) {
        return '${DateFormat('MMM d').format(selectedWeekStart)} - ${end.day}, ${end.year}';
      }
      return '${DateFormat('MMM d').format(selectedWeekStart)} - ${DateFormat('MMM d, yy').format(end)}';
    } else if (_tabController.index == 2) {
      if (_selectedDate.year == now.year && _selectedDate.month == now.month) {
        return 'This Month';
      }
      return DateFormat('MMMM yyyy').format(_selectedDate);
    } else if (_tabController.index == 3) {
      if (_selectedDate.year == now.year) {
        return 'This Year';
      }
      return '${_selectedDate.year}';
    }
    return '';
  }

  IconData _getTabIcon() {
    switch (_tabController.index) {
      case 0:
        return Icons.calendar_today_rounded;
      case 1:
        return Icons.calendar_view_week_rounded;
      case 2:
        return Icons.calendar_view_month_rounded;
      case 3:
        return Icons.calendar_month_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Future<DateTime?> _showPremiumYearPicker(BuildContext context, DateTime initialDate) async {
    int selectedYear = initialDate.year;
    final int currentYear = DateTime.now().year;

    // Calculate target offset: 3 columns, spacing 12, row height ~ 68.88
    int selectedIndex = selectedYear - 2000;
    int selectedRow = selectedIndex ~/ 3;
    double targetOffset = selectedRow * 68.88;
    final ScrollController yearScrollController = ScrollController();

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        bool autoScrolled = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!autoScrolled) {
              autoScrolled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  if (yearScrollController.hasClients) {
                    yearScrollController.animateTo(
                      targetOffset,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                    );
                  }
                });
              });
            }
            return Dialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Year',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      width: 280,
                      child: GridView.builder(
                        controller: yearScrollController,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: currentYear - 1999,
                        itemBuilder: (context, index) {
                          final year = 2000 + index;
                          final isSelected = year == selectedYear;
                          return InkWell(
                            onTap: () {
                              setDialogState(() => selectedYear = year);
                              Future.delayed(const Duration(milliseconds: 150), () {
                                if (context.mounted) Navigator.of(context).pop(DateTime(year, 1, 1));
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : AppColors.cardElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.white : AppColors.borderSubtle,
                                  width: 1.0,
                                ),
                                boxShadow: isSelected ? AppColors.whitePillShadow : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.black : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _showPremiumMonthPicker(BuildContext context, DateTime initialDate) async {
    int selectedMonth = initialDate.month;
    int selectedYear = initialDate.year;
    final int currentYear = DateTime.now().year;
    final int currentMonth = DateTime.now().month;
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                          onPressed: () => setDialogState(() => selectedYear--),
                        ),
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          onPressed: selectedYear < currentYear ? () => setDialogState(() => selectedYear++) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 275,
                      width: 280,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == selectedMonth;
                          final isDisabled = selectedYear == currentYear && month > currentMonth;
                          return InkWell(
                            onTap: isDisabled ? null : () {
                              setDialogState(() => selectedMonth = month);
                              Future.delayed(const Duration(milliseconds: 150), () {
                                if (context.mounted) Navigator.of(context).pop(DateTime(selectedYear, month, 1));
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.white 
                                    : (isDisabled ? AppColors.cardLight.withValues(alpha: 0.5) : AppColors.cardElevated),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.white : AppColors.borderSubtle,
                                  width: 1.0,
                                ),
                                boxShadow: isSelected ? AppColors.whitePillShadow : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                monthNames[index],
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.black 
                                      : (isDisabled ? AppColors.textMuted.withValues(alpha: 0.3) : AppColors.textPrimary),
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _showPremiumWeekPicker(BuildContext context, DateTime initialDate) async {
    int selectedMonth = initialDate.month;
    int selectedYear = initialDate.year;
    
    DateTime initialWeekStart = initialDate.subtract(Duration(days: initialDate.weekday - 1));
    DateTime currentSelectedWeek = DateTime(initialWeekStart.year, initialWeekStart.month, initialWeekStart.day);

    final int currentYear = DateTime.now().year;
    final int currentMonth = DateTime.now().month;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        ScrollController weekScrollController = ScrollController();
        bool autoScrolled = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            DateTime firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
            DateTime firstMonday = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));

            List<DateTime> weeks = [];
            DateTime currentMonday = firstMonday;
            while (currentMonday.month == selectedMonth || currentMonday.add(const Duration(days: 6)).month == selectedMonth) {
              weeks.add(currentMonday);
              currentMonday = currentMonday.add(const Duration(days: 7));
            }

            if (!autoScrolled) {
              autoScrolled = true;
              int selectedWeekIndex = weeks.indexWhere((w) => w.year == currentSelectedWeek.year && w.month == currentSelectedWeek.month && w.day == currentSelectedWeek.day);
              if (selectedWeekIndex == -1) selectedWeekIndex = 0;
              double targetOffset = selectedWeekIndex * 60.0;
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  if (weekScrollController.hasClients) {
                    weekScrollController.animateTo(
                      targetOffset,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                    );
                  }
                });
              });
            }

            return Dialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                          onPressed: () {
                            setDialogState(() {
                              if (selectedMonth == 1) {
                                selectedMonth = 12;
                                selectedYear--;
                              } else {
                                selectedMonth--;
                              }
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth)),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          onPressed: (selectedYear < currentYear || (selectedYear == currentYear && selectedMonth < currentMonth)) 
                              ? () {
                                  setDialogState(() {
                                    if (selectedMonth == 12) {
                                      selectedMonth = 1;
                                      selectedYear++;
                                    } else {
                                      selectedMonth++;
                                    }
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      width: 280,
                      child: ListView.separated(
                        controller: weekScrollController,
                        itemCount: weeks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final weekStart = weeks[index];
                          final weekEnd = weekStart.add(const Duration(days: 6));
                          final isSelected = weekStart.year == currentSelectedWeek.year && 
                                             weekStart.month == currentSelectedWeek.month && 
                                             weekStart.day == currentSelectedWeek.day;
                          
                          final now = DateTime.now();
                          final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
                          final isFuture = weekStart.isAfter(DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day));

                          return InkWell(
                            onTap: isFuture ? null : () {
                              setDialogState(() => currentSelectedWeek = weekStart);
                              Future.delayed(const Duration(milliseconds: 150), () {
                                if (context.mounted) Navigator.of(context).pop(weekStart);
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.white 
                                    : (isFuture ? AppColors.cardLight.withValues(alpha: 0.5) : AppColors.cardElevated),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.white : AppColors.borderSubtle,
                                  width: 1.0,
                                ),
                                boxShadow: isSelected ? AppColors.whitePillShadow : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Week ${index + 1}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : (isFuture ? AppColors.textMuted.withValues(alpha: 0.3) : AppColors.textPrimary),
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : (isFuture ? AppColors.textMuted.withValues(alpha: 0.3) : AppColors.textSecondary),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _previousPeriod,
          child: Container(
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
            child: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            DateTime? picked;
            
            if (_tabController.index == 1) {
              picked = await _showPremiumWeekPicker(context, _selectedDate);
            } else if (_tabController.index == 2) {
              picked = await _showPremiumMonthPicker(context, _selectedDate);
            } else if (_tabController.index == 3) {
              picked = await _showPremiumYearPicker(context, _selectedDate);
            } else {
              picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                helpText: 'Select Date',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.emeraldBright,
                        onPrimary: Colors.black,
                        surface: AppColors.card,
                        onSurface: AppColors.textPrimary,
                        outline: AppColors.borderSubtle,
                        outlineVariant: AppColors.borderSubtle,
                      ),
                      dialogTheme: const DialogThemeData(backgroundColor: AppColors.card),
                      datePickerTheme: DatePickerThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
                        ),
                        headerHelpStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                        dividerColor: AppColors.divider,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.emeraldBright,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
            }
            if (picked != null && !_isSameDay(picked, _selectedDate)) {
              setState(() {
                _selectedDate = picked!;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTabIcon(),
                  size: 16,
                  color: AppColors.emeraldBright,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPeriodText(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: _canGoNext() ? _nextPeriod : null,
          child: Opacity(
            opacity: _canGoNext() ? 1.0 : 0.35,
            child: Container(
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
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}