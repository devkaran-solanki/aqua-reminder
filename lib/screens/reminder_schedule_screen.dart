import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/reminder_alarm.dart';
import '../models/user_profile.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/custom_time_picker.dart';

/// Dedicated screen for managing hydration reminder schedules
/// Supports Auto (Smart Adaptive) and Manual (Custom Alarms with 1.5h preset)
class ReminderScheduleScreen extends StatefulWidget {
  const ReminderScheduleScreen({super.key});

  @override
  State<ReminderScheduleScreen> createState() => _ReminderScheduleScreenState();
}

class _ReminderScheduleScreenState extends State<ReminderScheduleScreen> {
  // Multi-select mode
  bool _isSelectionMode = false;
  final Set<String> _selectedAlarmIds = {};

  // Accordion expanded alarm ID (only one open at a time for clean UX)
  String? _expandedAlarmId;

  void _toggleSelectionMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedAlarmIds.clear();
      _expandedAlarmId = null;
    });
  }

  void _toggleSelectAlarm(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedAlarmIds.contains(id)) {
        _selectedAlarmIds.remove(id);
      } else {
        _selectedAlarmIds.add(id);
      }
    });
  }

  void _selectAll(List<ReminderAlarm> alarms) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedAlarmIds.length == alarms.length) {
        _selectedAlarmIds.clear();
      } else {
        _selectedAlarmIds.addAll(alarms.map((a) => a.id));
      }
    });
  }

  void _deleteSelected(WaterProvider provider) {
    if (_selectedAlarmIds.isEmpty) return;
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => _CyberConfirmDialog(
        title: 'Delete Selected Alarms?',
        message:
            'Are you sure you want to delete ${_selectedAlarmIds.length} selected reminder alarms?',
        confirmText: 'Delete',
        isDestructive: true,
        onConfirm: () {
          provider.deleteAlarms(_selectedAlarmIds.toList());
          setState(() {
            _selectedAlarmIds.clear();
            _isSelectionMode = false;
          });
        },
      ),
    );
  }

  void _resetToDefault(WaterProvider provider) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => _CyberConfirmDialog(
        title: 'Restore Default Schedule?',
        message:
            'This will regenerate reminder alarms spaced at 1.5-hour intervals from your wake time (${provider.profile.wakeTime}) to bedtime (${provider.profile.sleepTime}).',
        confirmText: 'Restore 1.5h Preset',
        isDestructive: false,
        onConfirm: () {
          provider.resetAlarmsToDefault();
          setState(() {
            _expandedAlarmId = null;
            _selectedAlarmIds.clear();
            _isSelectionMode = false;
          });
        },
      ),
    );
  }

  Future<void> _showAddAlarmSheet(BuildContext context, WaterProvider provider) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    List<int> selectedDays = [1, 2, 3, 4, 5, 6, 7];

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black.withOpacity(0.7),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle pill
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add Reminder Alarm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Custom Wheel Time Picker
                    Center(
                      child: CustomTimePicker(
                        initialTime: selectedTime,
                        backgroundColor: Colors.transparent,
                        fadeColor: AppColors.card,
                        showBorder: false,
                        accentColor: AppColors.cyanBright,
                        onChanged: (time) {
                          selectedTime = time;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Days of week selector
                    const Text(
                      'REPEAT ON',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DayChipsRow(
                      selectedDays: selectedDays,
                      onToggleDay: (day) {
                        setSheetState(() {
                          if (selectedDays.contains(day)) {
                            if (selectedDays.length > 1) {
                              selectedDays.remove(day);
                            }
                          } else {
                            selectedDays.add(day);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 22),

                    // Action Buttons (Cancel & Add Alarm)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(ctx);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: AppColors.borderSubtle,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                final h = selectedTime.hour.toString().padLeft(2, '0');
                                final m = selectedTime.minute.toString().padLeft(2, '0');
                                provider.addAlarm('$h:$m', days: selectedDays);
                                Navigator.pop(ctx);
                                HapticFeedback.lightImpact();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyanPrimary,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Add Alarm',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _editAlarmTime(
    BuildContext context,
    WaterProvider provider,
    ReminderAlarm alarm,
  ) async {
    HapticFeedback.lightImpact();
    TimeOfDay selectedTime = TimeOfDay(hour: alarm.hour, minute: alarm.minute);

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black.withOpacity(0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Edit Alarm Time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: CustomTimePicker(
                    initialTime: selectedTime,
                    backgroundColor: Colors.transparent,
                    fadeColor: AppColors.card,
                    showBorder: false,
                    accentColor: AppColors.cyanBright,
                    onChanged: (time) {
                      selectedTime = time;
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(ctx);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: AppColors.borderSubtle,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            final h = selectedTime.hour.toString().padLeft(2, '0');
                            final m = selectedTime.minute.toString().padLeft(2, '0');
                            provider.updateAlarm(alarm.copyWith(time: '$h:$m'));
                            Navigator.pop(ctx);
                            HapticFeedback.lightImpact();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyanPrimary,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save Time',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final aqua = AppColors.cyanPrimary;

    return Consumer<WaterProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final alarms = provider.customAlarms;
        final isManual = profile.reminderMode == ReminderMode.manual;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: AtmosphericBackground(
            child: RepaintBoundary(
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                    children: [
                    // Top Custom Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title
                      const Expanded(
                        child: Text(
                          'Reminder schedule',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),

                      // Actions (Selection Mode Done button)
                      if (isManual && _isSelectionMode)
                        TextButton(
                          onPressed: _toggleSelectionMode,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.cyanPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: AppColors.cyanPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Reminder Mode Capsule Switcher
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
                        // Auto (Smart Adaptive) Tab
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              provider.setReminderMode(ReminderMode.auto);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isManual
                                    ? aqua.withValues(alpha: 0.16)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isManual
                                      ? aqua.withValues(alpha: 0.35)
                                      : Colors.transparent,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 15,
                                    color: !isManual ? aqua : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Smart Adaptive',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: !isManual
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: !isManual
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Manual Schedule Tab
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              provider.setReminderMode(ReminderMode.manual);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isManual
                                    ? aqua.withValues(alpha: 0.16)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isManual
                                      ? aqua.withValues(alpha: 0.35)
                                      : Colors.transparent,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.alarm_rounded,
                                    size: 15,
                                    color: isManual ? aqua : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Manual Alarms',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isManual
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isManual
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selection Mode Actions Bar (when active)
                if (isManual && _isSelectionMode)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _selectAll(alarms),
                          icon: Icon(
                            _selectedAlarmIds.length == alarms.length
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: aqua,
                          ),
                          label: Text(
                            _selectedAlarmIds.length == alarms.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: TextStyle(
                              color: aqua,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_selectedAlarmIds.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _deleteSelected(provider),
                            icon: const Icon(Icons.delete_outline_rounded, size: 16),
                            label: Text('Delete (${_selectedAlarmIds.length})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.failure.withValues(alpha: 0.15),
                              foregroundColor: AppColors.failure,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: AppColors.failure,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Manual Alarms Header Actions (+ and 3-dots)
                if (isManual && !_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildAddAlarmButton(context, provider),
                        const SizedBox(width: 8),
                        _buildOverflowMenuButton(context, provider),
                      ],
                    ),
                  ),

                // Main Content View
                Expanded(
                  child: !isManual
                      ? _buildAutoModeView(provider)
                      : alarms.isEmpty
                          ? _buildEmptyState(provider)
                          : _buildAlarmsList(provider, alarms),
                ),
              ],
            ),

            // Bottom Continue button with smooth top gradient fade
            if (!_isSelectionMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0.0),
                        AppColors.background.withValues(alpha: 0.85),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.25, 1.0],
                    ),
                  ),
                  child: _buildContinueButton(context, isManual),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);
},
    );
  }

  /// Add alarm button placed next to 3-dots
  Widget _buildAddAlarmButton(BuildContext context, WaterProvider provider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showAddAlarmSheet(context, provider);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: AppColors.cyanPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  /// 3-dots options menu for manual alarms
  Widget _buildOverflowMenuButton(BuildContext context, WaterProvider provider) {
    return PopupMenuButton<String>(
      tooltip: 'Options',
      offset: const Offset(0, 44),
      color: AppColors.cardElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      onSelected: (val) {
        if (val == 'select') {
          _toggleSelectionMode();
        } else if (val == 'reset') {
          _resetToDefault(provider);
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'select',
          child: Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: AppColors.cyanPrimary,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                'Select alarms',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              Icon(
                Icons.restart_alt_rounded,
                color: AppColors.cyanPrimary,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                'Reset to default',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.more_vert_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Bottom Continue Button
  Widget _buildContinueButton(BuildContext context, bool isManual) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyanPrimary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isManual
                  ? 'Continue with Manual Alarms'
                  : 'Continue with Smart Adaptive',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  /// View shown when Auto (Smart Adaptive) mode is selected
  Widget _buildAutoModeView(WaterProvider provider) {
    final aqua = AppColors.cyanPrimary;
    final profile = provider.profile;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: aqua.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: aqua.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.cyanBright,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'SMART ADAPTIVE ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppColors.cyanBright,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Title
          const Text(
            'Dynamic Water Pacing',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          const Text(
            'AQUÉA continuously calculates the best times for you to drink based on your daily goal, cup volume, and time elapsed since your last sip.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),

          // Feature cards (No giant enclosing box)
          _buildAdaptiveFeatureTile(
            icon: Icons.wb_sunny_rounded,
            iconColor: AppColors.warning,
            title: 'Active Schedule',
            description:
                '${profile.wakeTime} to ${profile.sleepTime} • Pauses automatically while you sleep',
          ),
          const SizedBox(height: 10),
          _buildAdaptiveFeatureTile(
            icon: Icons.bolt_rounded,
            iconColor: AppColors.cyanBright,
            title: 'Self-Adjusting Intervals',
            description:
                'Automatically reschedules when you drink, so you\'re only reminded when you actually need water',
          ),
          const SizedBox(height: 10),
          _buildAdaptiveFeatureTile(
            icon: Icons.notifications_off_outlined,
            iconColor: AppColors.success,
            title: 'Zero Alarm Fatigue',
            description:
                'No rigid alarms or constant schedule maintenance required',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAdaptiveFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state when all alarms are deleted
  Widget _buildEmptyState(WaterProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.alarm_off_rounded,
                size: 34,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Reminder Alarms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have cleared all reminder alarms. Add a custom alarm or restore the 1.5-hour default schedule.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _resetToDefault(provider),
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Restore 1.5h Preset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyanPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List of manual alarms
  Widget _buildAlarmsList(
    WaterProvider provider,
    List<ReminderAlarm> alarms,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
      child: Column(
        children: alarms.map((alarm) {
          final isExpanded = _expandedAlarmId == alarm.id;
          final isSelected = _selectedAlarmIds.contains(alarm.id);

          return Padding(
            key: ValueKey(alarm.id),
            padding: const EdgeInsets.only(bottom: 10),
            child: _AlarmCard(
              key: ValueKey(alarm.id),
              alarm: alarm,
              isExpanded: isExpanded,
              isSelectionMode: _isSelectionMode,
              isSelected: isSelected,
              onToggleExpand: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _expandedAlarmId = isExpanded ? null : alarm.id;
                });
              },
              onToggleSelect: () => _toggleSelectAlarm(alarm.id),
              onToggleEnable: () => provider.toggleAlarm(alarm.id),
              onDelete: () {
                HapticFeedback.mediumImpact();
                provider.deleteAlarm(alarm.id);
              },
              onEditTime: () => _editAlarmTime(context, provider, alarm),
              onToggleDay: (day) {
                final newDays = List<int>.from(alarm.days);
                if (newDays.contains(day)) {
                  if (newDays.length > 1) newDays.remove(day);
                } else {
                  newDays.add(day);
                }
                provider.updateAlarm(alarm.copyWith(days: newDays));
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Individual alarm card with time, toggle switch, and expandable drawer
class _AlarmCard extends StatefulWidget {
  final ReminderAlarm alarm;
  final bool isExpanded;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleSelect;
  final VoidCallback onToggleEnable;
  final VoidCallback onDelete;
  final VoidCallback onEditTime;
  final ValueChanged<int> onToggleDay;

  const _AlarmCard({
    super.key,
    required this.alarm,
    required this.isExpanded,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onToggleExpand,
    required this.onToggleSelect,
    required this.onToggleEnable,
    required this.onDelete,
    required this.onEditTime,
    required this.onToggleDay,
  });

  @override
  State<_AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<_AlarmCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _chevronAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 170),
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.88, curve: Curves.easeIn),
    );
    _chevronAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void didUpdateWidget(_AlarmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aqua = AppColors.cyanPrimary;

    final drawerContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.borderSubtle,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Days of week selector
              _DayChipsRow(
                selectedDays: widget.alarm.days,
                onToggleDay: widget.onToggleDay,
              ),
              const SizedBox(height: 14),

              // Actions row: Delete & Edit Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delete Action
                  GestureDetector(
                    onTap: widget.onDelete,
                    behavior: HitTestBehavior.opaque,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 14,
                          color: AppColors.failure,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.failure,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Time Action
                  GestureDetector(
                    onTap: widget.onEditTime,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: aqua),
                        const SizedBox(width: 4),
                        Text(
                          'Change Time',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: aqua,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final isEnabled = widget.alarm.isEnabled;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: drawerContent,
        builder: (context, child) {
          final progress = _expandAnimation.value;
          final borderColor = widget.isSelected
              ? aqua
              : Color.lerp(
                  AppColors.borderSubtle,
                  aqua.withValues(alpha: 0.35),
                  progress,
                )!;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: widget.isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main Trigger Tile
                GestureDetector(
                  onTap: widget.isSelectionMode
                      ? widget.onToggleSelect
                      : widget.onToggleExpand,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Multi-select Checkbox
                        if (widget.isSelectionMode) ...[
                          GestureDetector(
                            onTap: widget.onToggleSelect,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isSelected ? aqua : Colors.transparent,
                                border: Border.all(
                                  color: widget.isSelected ? aqua : AppColors.textMuted,
                                  width: 1.5,
                                ),
                              ),
                              child: widget.isSelected
                                  ? const Center(
                                      child: Icon(Icons.check_rounded,
                                          size: 14, color: Colors.black),
                                    )
                                  : null,
                            ),
                          ),
                        ],

                        // Big Bold Time Display with smooth color fade animation
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeInOutCubic,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: isEnabled
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                      letterSpacing: -0.5,
                                    ),
                                    child: Text(widget.alarm.formattedHourMinute),
                                  ),
                                  const SizedBox(width: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeInOutCubic,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isEnabled ? aqua : AppColors.textMuted,
                                    ),
                                    child: Text(widget.alarm.amPm),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeInOutCubic,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isEnabled
                                      ? AppColors.textSecondary
                                      : AppColors.textMuted.withValues(alpha: 0.6),
                                ),
                                child: Text(widget.alarm.repetitionSummary),
                              ),
                            ],
                          ),
                        ),

                        // Toggle Switch with smooth hardware-accelerated slider animation
                        if (!widget.isSelectionMode) ...[
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onToggleEnable();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: _CyberSwitch(isEnabled: isEnabled),
                          ),
                          const SizedBox(width: 8),

                          // Rotating Expand Chevron (matching InstagramDropdown)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: RotationTransition(
                              turns: _chevronAnimation,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color.lerp(
                                  AppColors.textMuted,
                                  aqua,
                                  progress,
                                ),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Smooth Expanding Drawer Body (Hardware accelerated ClipRect + Align + Fade)
                if (!widget.isSelectionMode)
                  ClipRect(
                    clipBehavior: Clip.hardEdge,
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: progress,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: child,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom Cyber Glowing Switch Toggle with Smooth Hardware-Accelerated Sliding Animation
class _CyberSwitch extends StatelessWidget {
  final bool isEnabled;

  const _CyberSwitch({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final aqua = AppColors.cyanPrimary;
    const duration = Duration(milliseconds: 260);
    const curve = Curves.easeInOutCubic;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: isEnabled ? aqua.withValues(alpha: 0.3) : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? aqua : AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: AnimatedAlign(
          duration: duration,
          curve: curve,
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled ? aqua : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// 7-day selector chips row (Sun - Sat)
class _DayChipsRow extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<int> onToggleDay;

  const _DayChipsRow({
    required this.selectedDays,
    required this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    final aqua = AppColors.cyanPrimary;
    // Week order matching user screenshot: Sun(7), Mon(1), Tue(2), Wed(3), Thu(4), Fri(5), Sat(6)
    const weekDays = [
      {'label': 'Sun', 'day': 7},
      {'label': 'Mon', 'day': 1},
      {'label': 'Tue', 'day': 2},
      {'label': 'Wed', 'day': 3},
      {'label': 'Thu', 'day': 4},
      {'label': 'Fri', 'day': 5},
      {'label': 'Sat', 'day': 6},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.map((item) {
        final day = item['day'] as int;
        final label = item['label'] as String;
        final isSelected = selectedDays.contains(day);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggleDay(day);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected
                  ? aqua.withValues(alpha: 0.16)
                  : AppColors.cardElevated,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: isSelected
                    ? aqua.withValues(alpha: 0.6)
                    : AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? aqua : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Confirmation Dialog matching Aquea Cyber Obsidian Theme
class _CyberConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const _CyberConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.isDestructive,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final aqua = AppColors.cyanPrimary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.cardElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDestructive ? AppColors.failure : aqua,
                      foregroundColor:
                          isDestructive ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

