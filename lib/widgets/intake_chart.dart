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
            'No data yet.\nStart logging water to see your analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final maxValue = data.values.fold<double>(0, (a, b) => a > b ? a : b);
    final rawMax = goalLine != null && goalLine! > maxValue ? goalLine! : maxValue;
    final baseMax = rawMax < 1000 ? 1000.0 : rawMax;

    double interval = 200;
    if (baseMax <= 1000) {
      interval = 200;
    } else if (baseMax <= 2500) {
      interval = 500;
    } else if (baseMax <= 6000) {
      interval = 1000;
    } else if (baseMax <= 12000) {
      interval = 2000;
    } else if (baseMax <= 30000) {
      interval = 5000;
    } else if (baseMax <= 60000) {
      interval = 10000;
    } else if (baseMax <= 150000) {
      interval = 30000;
    } else {
      interval = 50000;
    }

    double effectiveMax = ((baseMax / interval).ceil() * interval).toDouble();
    if (effectiveMax - baseMax < interval * 0.1) {
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
              getTooltipColor: (group) => AppColors.cardElevated,
              tooltipBorder: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final rawLabel = data.keys.elementAt(groupIndex);
                final labelParts = rawLabel.split('_');
                final tooltipLabel = labelParts.length > 1 ? labelParts[1] : rawLabel;

                return BarTooltipItem(
                  '$tooltipLabel\n${rod.toY.toInt()} $unit',
                  const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
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
                        color: AppColors.borderSubtle,
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      axisLabel,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: goalLine != null
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goalLine!,
                      color: AppColors.emeraldPrimary.withValues(alpha: 0.5),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: AppColors.emeraldBright,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                        labelResolver: (_) => 'GOAL',
                      ),
                    ),
                  ],
                )
              : null,
          barGroups: data.entries.toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final value = mapEntry.value.value;
            final isAboveGoal = goalLine != null && value >= goalLine!;

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
                        ? const [
                            AppColors.emeraldPrimary,
                            AppColors.emeraldBright,
                          ]
                        : const [
                            AppColors.cardLight,
                            AppColors.cardHover,
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
