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

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textTertiary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildDateNavigation(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStatsCards(provider),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 260,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.surfaceLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getChartTitle(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
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

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
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
      childAspectRatio: 1.6,
      children: stats.map((stat) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: stat.color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: stat.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(stat.icon, color: stat.color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      stat.label,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                stat.value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<_StatData> _getStats(WaterProvider provider) {
    switch (_tabController.index) {
      case 0: // Day
        final dayIntake = provider.getIntakeForDate(_selectedDate);
        final dayEntries = _getEntriesForDate(provider, _selectedDate);
        final goal = provider.dailyGoalMl;
        final dayProgress = goal > 0 ? (dayIntake / goal).clamp(0.0, 1.0) : 0.0;
        final isGoalMet = dayIntake >= goal;

        return [
          _StatData(
            icon: Icons.water_drop,
            label: 'Total Intake',
            value: _formatMl(dayIntake),
            color: AppColors.waterBlue,
          ),
          _StatData(
            icon: Icons.flag,
            label: 'Goal',
            value: _formatMl(goal),
            color: AppColors.primary,
          ),
          _StatData(
            icon: Icons.format_list_numbered,
            label: 'Entries',
            value: '${dayEntries.length}',
            color: AppColors.secondary,
          ),
          _StatData(
            icon: Icons.percent,
            label: 'Completion',
            value: '${(dayProgress * 100).toInt()}%',
            color: isGoalMet
                ? AppColors.success
                : AppColors.warning,
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
            icon: Icons.water_drop,
            label: 'Total Intake',
            value: _formatMl(totalWeek),
            color: AppColors.waterBlue,
          ),
          _StatData(
            icon: Icons.show_chart,
            label: 'Daily Average',
            value: _formatMl(avg),
            color: AppColors.primary,
          ),
          _StatData(
            icon: Icons.emoji_events,
            label: 'Goals Met',
            value: '$goalDays / $goalMax',
            color: AppColors.warning,
          ),
          _StatData(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${provider.currentStreak} days',
            color: AppColors.error,
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
            icon: Icons.water_drop,
            label: 'Total Intake',
            value: _formatMl(totalMonth),
            color: AppColors.waterBlue,
          ),
          _StatData(
            icon: Icons.show_chart,
            label: 'Daily Average',
            value: _formatMl(avg),
            color: AppColors.primary,
          ),
          _StatData(
            icon: Icons.star,
            label: 'Best Day',
            value: _formatMl(bestDayIntake),
            color: AppColors.warning,
          ),
          _StatData(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${provider.currentStreak} days',
            color: AppColors.error,
          ),
        ];
      case 3: // Year
        final date = _selectedDate;
        final monthlyTotals = provider.getMonthlyTotals(date.year);
        final totalYear = monthlyTotals.values.fold<int>(0, (a, b) => a + b);
        final monthsWithData = monthlyTotals.values.where((v) => v > 0).length;
        final avgMonthly = monthsWithData > 0 ? totalYear ~/ monthsWithData : 0;
        final avgDaily = monthsWithData > 0 ? totalYear ~/ (monthsWithData * 30) : 0;

        return [
          _StatData(
            icon: Icons.water_drop,
            label: 'Total Intake',
            value: _formatLiters(totalYear),
            color: AppColors.waterBlue,
          ),
          _StatData(
            icon: Icons.calendar_month,
            label: 'Monthly Avg',
            value: _formatLiters(avgMonthly),
            color: AppColors.primary,
          ),
          _StatData(
            icon: Icons.show_chart,
            label: 'Daily Avg',
            value: _formatMl(avgDaily),
            color: AppColors.secondary,
          ),
          _StatData(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${provider.currentStreak} days',
            color: AppColors.error,
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildChart(WaterProvider provider) {
    switch (_tabController.index) {
      case 0: // Day - hourly
        final hourlyData = provider.getHourlyTotals(_selectedDate);
        final Map<String, double> chartData = {};
        for (int i = 0; i < 24; i++) {
          final String axisLabel = (i % 4 == 0) ? '$i' : '|';
          chartData['${axisLabel}_${i}h'] = (hourlyData[i] ?? 0).toDouble();
        }
        return IntakeBarChart(
          data: chartData,
          goalLine: null,
        );
      case 1: // Week - daily
        final date = _selectedDate;
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final dailyTotals = provider.getDailyTotals(weekStart, weekEnd);
        final Map<String, double> chartData = {};
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        int i = 0;
        for (final entry in dailyTotals.entries) {
          if (i < dayNames.length) {
            chartData[dayNames[i]] = entry.value.toDouble();
          }
          i++;
        }
        return IntakeBarChart(
          data: chartData,
          goalLine: provider.dailyGoalMl.toDouble(),
        );
      case 2: // Month - daily
        final date = _selectedDate;
        final monthStart = DateTime(date.year, date.month, 1);
        final monthEnd = DateTime(date.year, date.month + 1, 0);
        final dailyTotals = provider.getDailyTotals(monthStart, monthEnd);
        final Map<String, double> chartData = {};
        for (final entry in dailyTotals.entries) {
          final int day = entry.key.day;
          final String axisLabel = (day == 1 || day % 5 == 0) ? '$day' : '|';
          chartData['${axisLabel}_$day'] = entry.value.toDouble();
        }
        return IntakeBarChart(
          data: chartData,
          goalLine: provider.dailyGoalMl.toDouble(),
        );
      case 3: // Year - monthly
        final date = _selectedDate;
        final monthlyTotals = provider.getMonthlyTotals(date.year);
        final monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final Map<String, double> chartData = {};
        for (int m = 1; m <= 12; m++) {
          chartData[monthNames[m - 1]] = (monthlyTotals[m] ?? 0).toDouble();
        }
        // Monthly goal = daily goal * 30
        return IntakeBarChart(
          data: chartData,
          goalLine: (provider.dailyGoalMl * 30).toDouble(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailedBreakdown(WaterProvider provider) {
    if (_tabController.index == 0) {
      // Day view: show timeline of entries
      final entries = _getEntriesForDate(provider, _selectedDate);
      if (entries.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Center(
            child: Text(
              _isToday(_selectedDate) ? 'No entries today yet' : 'No entries on this day',
              style: const TextStyle(color: AppColors.textTertiary),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.waterBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('h:mm a').format(entry.timestamp),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.amount} ml',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
    if (_tabController.index == 1) {
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
          ? 'This Week'
          : '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}';
          
      return _buildDailyBreakdownList(title, dailyTotals, provider.dailyGoalMl);
    }

    if (_tabController.index == 2) {
      final date = _selectedDate;
      final monthStart = DateTime(date.year, date.month, 1);
      final monthEnd = DateTime(date.year, date.month + 1, 0);
      final dailyTotals = provider.getDailyTotals(monthStart, monthEnd);
      
      final now = DateTime.now();
      final isThisMonth = date.year == now.year && date.month == now.month;
      return _buildDailyBreakdownList(
          isThisMonth ? 'This Month' : DateFormat('MMMM yyyy').format(date), 
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isThisYear ? 'This Year Breakdown' : '${date.year} Monthly Breakdown',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
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
                    width: 70,
                    child: Text(
                      monthNames[i].substring(0, 3),
                      style: TextStyle(
                        color: isMonthValid
                            ? AppColors.textSecondary
                            : AppColors.textTertiary.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            AppColors.surfaceLight.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          total >= monthGoal && isMonthValid
                              ? AppColors.success
                              : (isMonthValid ? AppColors.waterBlue : AppColors.surfaceLight.withValues(alpha: 0.3)),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 50,
                    child: Text(
                      _formatLiters(total),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: isMonthValid
                            ? AppColors.textPrimary
                            : AppColors.textTertiary.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
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
                    width: 60,
                    child: Text(
                      isToday
                          ? 'Today'
                          : DateFormat('E d').format(entry.key),
                      style: TextStyle(
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            AppColors.surfaceLight.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          metGoal ? AppColors.success : AppColors.waterBlue,
                        ),
                        minHeight: 8,
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
                            ? AppColors.success
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (metGoal)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.check_circle,
                          color: AppColors.success, size: 16),
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
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Year', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
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
                        // Display year from 2000 to currentYear
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
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceLight.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  color: isSelected ? AppColors.background : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                          onPressed: () => setDialogState(() => selectedYear--),
                        ),
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          onPressed: selectedYear < currentYear ? () => setDialogState(() => selectedYear++) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : (isDisabled ? AppColors.surface : AppColors.surfaceLight.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                monthNames[index],
                                style: TextStyle(
                                  color: isSelected 
                                      ? AppColors.background 
                                      : (isDisabled ? AppColors.textTertiary.withValues(alpha: 0.3) : AppColors.textPrimary),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
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
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : (isFuture ? AppColors.surface : AppColors.surfaceLight.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Week ${index + 1}',
                                    style: TextStyle(
                                      color: isSelected ? AppColors.background : (isFuture ? AppColors.textTertiary.withValues(alpha: 0.3) : AppColors.textPrimary),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
                                    style: TextStyle(
                                      color: isSelected ? AppColors.background : (isFuture ? AppColors.textTertiary.withValues(alpha: 0.3) : AppColors.textSecondary),
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
        IconButton(
          onPressed: _previousPeriod,
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
        ),
        InkWell(
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
                        primary: AppColors.primary,
                        onPrimary: AppColors.background,
                        surface: AppColors.surface,
                        onSurface: AppColors.textPrimary,
                        outline: AppColors.surfaceLight,
                        outlineVariant: AppColors.surfaceLight,
                      ),
                      dialogBackgroundColor: AppColors.surface,
                      datePickerTheme: DatePickerThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        headerHelpStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        dividerColor: AppColors.surfaceLight,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    _getTabIcon(),
                    key: ValueKey<int>(_tabController.index),
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: Text(
                    _getPeriodText(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: _canGoNext() ? _nextPeriod : null,
          icon: Icon(
            Icons.chevron_right,
            color: _canGoNext() ? AppColors.textPrimary : AppColors.textTertiary,
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
