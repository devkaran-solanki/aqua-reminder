import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class IntakeBarChart extends StatelessWidget {
  final Map<String, double> data; // label -> value in ml
  final double? goalLine;
  final String unit;

  const IntakeBarChart({
    super.key,
    required this.data,
    this.goalLine,
    this.unit = 'ml',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No data yet.\nStart drinking water to see your stats!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final maxValue = data.values.fold<double>(0, (a, b) => a > b ? a : b);
    final rawMax = goalLine != null && goalLine! > maxValue ? goalLine! : maxValue;
    final baseMax = rawMax < 1000 ? 1000.0 : rawMax;
    
    double interval = 200;
    if (baseMax <= 1000) interval = 200;
    else if (baseMax <= 2500) interval = 500;
    else if (baseMax <= 6000) interval = 1000;
    else if (baseMax <= 12000) interval = 2000;
    else if (baseMax <= 30000) interval = 5000;
    else if (baseMax <= 60000) interval = 10000;
    else if (baseMax <= 150000) interval = 30000;
    else interval = 50000;
    
    double effectiveMax = ((baseMax / interval).ceil() * interval).toDouble();
    if (effectiveMax - baseMax < interval * 0.1) {
      // Add one more interval if it's too close to the top to give visual headroom
      effectiveMax += interval; 
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: effectiveMax,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final rawLabel = data.keys.elementAt(groupIndex);
                final labelParts = rawLabel.split('_');
                final tooltipLabel = labelParts.length > 1 ? labelParts[1] : rawLabel;
                
                return BarTooltipItem(
                  '$tooltipLabel\n${rod.toY.toInt()} $unit',
                  const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value > meta.max) return const SizedBox.shrink();
                  final l = value / 1000;
                  String label = (l == l.toInt()) 
                      ? '${l.toInt()}L' 
                      : '${l.toStringAsFixed(1)}L';
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  
                  final rawLabel = data.keys.elementAt(index);
                  final labelParts = rawLabel.split('_');
                  final axisLabel = labelParts[0];

                  if (axisLabel == '|') {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 1,
                        height: 4,
                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      axisLabel,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.surfaceLight.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: goalLine != null
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goalLine!,
                      color: AppColors.primary.withValues(alpha: 0.5),
                      strokeWidth: 2,
                      dashArray: [8, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        labelResolver: (_) => 'Goal',
                      ),
                    ),
                  ],
                )
              : null,
          barGroups: data.entries.toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final value = mapEntry.value.value;
            final isAboveGoal =
                goalLine != null && value >= goalLine!;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: data.length > 12 ? 8 : 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    colors: isAboveGoal
                        ? [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ]
                        : [
                            AppColors.waterBlueDark,
                            AppColors.waterBlue,
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
