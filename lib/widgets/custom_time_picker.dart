import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onChanged;

  const CustomTimePicker({super.key, required this.initialTime, required this.onChanged});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedPeriod; // 0 = AM, 1 = PM

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hourOfPeriod == 0
        ? 12
        : widget.initialTime.hourOfPeriod;
    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = widget.initialTime.period == DayPeriod.am ? 0 : 1;

    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
    _periodController = FixedExtentScrollController(
      initialItem: _selectedPeriod,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    int finalHour = _selectedHour;
    if (_selectedPeriod == 1 && finalHour < 12) finalHour += 12; // PM
    if (_selectedPeriod == 0 && finalHour == 12) finalHour = 0; // AM

    widget.onChanged(TimeOfDay(hour: finalHour, minute: _selectedMinute));
  }

  @override
  Widget build(BuildContext context) {
    const double itemExtent = 50;

    return Container(
      height: itemExtent * 5, // Exactly 5 rows visible
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.surfaceLight.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Middle row highlight
          Container(
            height: itemExtent,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWheel(
                controller: _hourController,
                itemCount: 12,
                itemExtent: itemExtent,
                selectedIndex: _selectedHour - 1,
                builder: (index) => (index + 1).toString().padLeft(2, '0'),
                onChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedHour = index + 1);
                  _notifyChange();
                },
                isLooping: true,
              ),
              const Text(
                ':',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 0.8,
                ),
              ),
              _buildWheel(
                controller: _minuteController,
                itemCount: 60,
                itemExtent: itemExtent,
                selectedIndex: _selectedMinute,
                builder: (index) => index.toString().padLeft(2, '0'),
                onChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedMinute = index);
                  _notifyChange();
                },
                isLooping: true,
              ),
              _buildWheel(
                controller: _periodController,
                itemCount: 2,
                itemExtent: itemExtent,
                selectedIndex: _selectedPeriod,
                builder: (index) => index == 0 ? 'AM' : 'PM',
                onChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedPeriod = index);
                  _notifyChange();
                },
                isLooping: false,
              ),
            ],
          ),

          // Gradients to fade out top and bottom rows
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: itemExtent * 2,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surface,
                      AppColors.surface.withValues(alpha: 0.5),
                      AppColors.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: itemExtent * 2,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.surface,
                      AppColors.surface.withValues(alpha: 0.5),
                      AppColors.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required double itemExtent,
    required int selectedIndex,
    required String Function(int) builder,
    required ValueChanged<int> onChanged,
    bool isLooping = true,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: itemExtent,
        physics: const FixedExtentScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        perspective: 0.005,
        diameterRatio: 1.5,
        onSelectedItemChanged: (index) {
          if (isLooping) {
            onChanged(index % itemCount);
          } else {
            onChanged(index);
          }
        },
        childDelegate: isLooping
            ? ListWheelChildLoopingListDelegate(
                children: List.generate(
                  itemCount,
                  (index) => _buildWheelItemText(
                    text: builder(index),
                    isSelected: (selectedIndex % itemCount) == index,
                  ),
                ),
              )
            : ListWheelChildBuilderDelegate(
                childCount: itemCount,
                builder: (context, index) => _buildWheelItemText(
                  text: builder(index),
                  isSelected: selectedIndex == index,
                ),
              ),
      ),
    );
  }

  Widget _buildWheelItemText({required String text, required bool isSelected}) {
    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          fontSize: isSelected ? 26 : 20,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected
              ? AppColors.primaryLight
              : AppColors.textSecondary.withValues(alpha: 0.5),
          letterSpacing: isSelected ? 1 : 0,
        ),
        child: Text(text),
      ),
    );
  }
}
