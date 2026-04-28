import os

with open('c:\\Users\\devka\\AppData\\Roaming\\Code\\User\\workspaceStorage\\32a8187f1c334ab42622a3c260305fc0\\GitHub.copilot-chat\\chat-session-resources\\e47eb327-da5d-40e1-83b0-d318e7a427d5\\call_MHxYTktJZGxJQWkyYUVKY2R5WUs__vscode-1777386473501\\content.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# the text contains some powershell output at the top, let's skip it
lines = text.split('\n')
for i, line in enumerate(lines):
    if line.strip() == 'data: chartData,':
        content_lines = lines[i:]
        break

# Now we need the top part of the file.
top_part = '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/water_entry.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/intake_chart.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

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

          // Tab Bar
          Padding(
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
        );
      },
    );
  }

  Widget _buildStatsCards(WaterProvider provider) {
    String average = '0';
    String best = '0';
    String total = '0';
    String completion = '0%';

    if (_tabController.index == 0) {
      final entries = _getEntriesForDate(provider, _selectedDate);
      final dayTotal = entries.fold(0, (sum, e) => sum + e.amount);
      average = '\ ml';
      best = '\ ml';
      total = '\ ml';
      completion = '\%';
    } else if (_tabController.index == 1) {
      final start = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      final entries = provider.getDailyTotals(start, end);
      final weekTotal = entries.values.fold(0, (sum, e) => sum + e);
      average = '\ ml';
      best = '\ ml';
      total = '\ L';
      completion = '\%';
    } else if (_tabController.index == 2) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      final entries = provider.getDailyTotals(start, end);
      final monthTotal = entries.values.fold(0, (sum, e) => sum + e);
      average = '\ ml';
      best = '\ ml';
      total = '\ L';
      completion = '\%';
    } else if (_tabController.index == 3) {
      final monthTotals = provider.getMonthlyTotals(_selectedDate.year);
      final yearTotal = monthTotals.values.fold(0, (sum, e) => sum + e);
      average = '\ ml';
      best = '\ ml';
      total = '\ L';
      completion = '\%';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Average', average, Icons.monitor_weight_outlined),
              Container(width: 1, height: 40, color: AppColors.surfaceLight),
              _buildStatItem('Best', best, Icons.emoji_events_outlined),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceLight, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Total', total, Icons.water_drop_outlined, color: AppColors.waterBlue),
              Container(width: 1, height: 40, color: AppColors.surfaceLight),
              _buildStatItem('Completion', completion, Icons.check_circle_outline, color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color color = AppColors.primary}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(WaterProvider provider) {
    if (_tabController.index == 0) {
      final hourly = provider.getHourlyTotals(_selectedDate);
      final Map<String, double> chartData = {};
      for (int i = 0; i < 24; i += 3) {
        double sum = 0;
        for (int j = 0; j < 3; j++) sum += hourly[i + j] ?? 0;
        final hourFormat = DateFormat('h a').format(DateTime(2020, 1, 1, i));
        chartData[hourFormat] = sum;
      }
      return IntakeBarChart(data: chartData, goalLine: provider.dailyGoalMl / 8);
    } else if (_tabController.index == 1) {
      final start = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      final daily = provider.getDailyTotals(start, end);
      final Map<String, double> chartData = {};
      daily.forEach((date, value) {
        chartData[DateFormat('E').format(date)] = value.toDouble();
      });
      return IntakeBarChart(data: chartData, goalLine: provider.dailyGoalMl.toDouble());
    } else if (_tabController.index == 2) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      final daily = provider.getDailyTotals(start, end);
      final Map<String, double> chartData = {};
      daily.forEach((date, value) {
        if (date.day % 5 == 1 || date.day == end.day) {
          chartData[date.day.toString()] = value.toDouble();
        } else {
          chartData['_'] = value.toDouble(); // Hidden labels
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
'''

with open('lib/screens/reports_screen.dart', 'w', encoding='utf-8') as f:
    f.write(top_part + '\n'.join(content_lines))

print("Created reports_screen.dart")
