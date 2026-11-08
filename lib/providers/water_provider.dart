import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_entry.dart';
import '../models/user_profile.dart';
import '../models/reminder_alarm.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

class WaterProvider extends ChangeNotifier {
  List<WaterEntry> _entries = [];
  int _dailyGoalMl = WaterDefaults.dailyGoalMl;
  int _selectedSize = WaterDefaults.defaultSelectedSize;
  int? _lastCustomSize;
  bool _isLoaded = false;
  UserProfile _profile = const UserProfile();
  List<ReminderAlarm> _customAlarms = [];

  // Getters
  List<WaterEntry> get entries => _entries;
  int get dailyGoalMl => _dailyGoalMl;
  int get selectedSize => _selectedSize;
  int? get lastCustomSize => _lastCustomSize;
  bool get isLoaded => _isLoaded;
  UserProfile get profile => _profile;
  bool get isOnboardingComplete => _profile.onboardingComplete;
  MeasureUnit get unit => _profile.unit;
  ReminderMode get reminderMode => _profile.reminderMode;
  List<ReminderAlarm> get customAlarms => List.unmodifiable(_customAlarms);

  // Format amount respecting user's unit preference
  String formatAmount(int ml) => UnitConverter.formatAmount(ml, _profile.unit);
  String formatAmountShort(int ml) =>
      UnitConverter.formatAmountShort(ml, _profile.unit);
  String get unitLabel => UnitConverter.unitLabel(_profile.unit);

  // Today's entries
  List<WaterEntry> get todayEntries {
    final now = DateTime.now();
    return _entries.where((e) {
      return e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Today's total intake
  int get todayIntake {
    return todayEntries.fold(0, (sum, e) => sum + e.amount);
  }

  // Suggest Next Drinking Time
  DateTime? get nextDrinkingTime {
    if (isGoalMet) return null;
    
    final wakeParts = profile.wakeTime.split(':');
    final sleepParts = profile.sleepTime.split(':');
    if (wakeParts.length != 2 || sleepParts.length != 2) return null;

    int wakeHour = int.tryParse(wakeParts[0]) ?? 7;
    int wakeMinute = int.tryParse(wakeParts[1]) ?? 0;
    
    int sleepHour = int.tryParse(sleepParts[0]) ?? 23;
    int sleepMinute = int.tryParse(sleepParts[1]) ?? 0;

    final now = DateTime.now();
    DateTime wakeDt = DateTime(now.year, now.month, now.day, wakeHour, wakeMinute);
    DateTime sleepDt = DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
    
    if (sleepDt.isBefore(wakeDt)) {
      sleepDt = sleepDt.add(const Duration(days: 1));
    }

    // If currently sleeping
    if (now.isBefore(wakeDt)) {
      return wakeDt;
    } else if (now.isAfter(sleepDt)) {
      return wakeDt.add(const Duration(days: 1));
    }

    final totalMinutesAwake = sleepDt.difference(wakeDt).inMinutes;
    if (totalMinutesAwake <= 0) return null;
    
    // Estimate drinks remaining based on average size if selectedSize is 0 somehow
    final int size = selectedSize > 0 ? selectedSize : 250;
    final int drinksNeeded = (dailyGoalMl / size).ceil();
    if (drinksNeeded <= 0) return null;

    final int intervalMinutes = totalMinutesAwake ~/ drinksNeeded;
    
    // Find next interval after the last drink or wake time
    DateTime lastDrinkTime = wakeDt;
    final entries = todayEntries;
    if (entries.isNotEmpty) {
      if (entries.first.timestamp.isAfter(wakeDt)) {
        lastDrinkTime = entries.first.timestamp;
      }
    }
    
    DateTime nextTime = lastDrinkTime.add(Duration(minutes: intervalMinutes));
    
    // Fast forward to future
    while (nextTime.isBefore(now)) {
      nextTime = nextTime.add(Duration(minutes: intervalMinutes));
    }
    
    // Check if it overshoots sleep
    if (nextTime.isAfter(sleepDt)) {
      if (now.isAfter(sleepDt)) {
        return wakeDt.add(const Duration(days: 1));
      }
      return null;
    }
    
    return nextTime;
  }

  // Progress (0.0 to 1.0, capped at 1.0)
  double get todayProgress {
    if (_dailyGoalMl == 0) return 0;
    return (todayIntake / _dailyGoalMl).clamp(0.0, 1.0);
  }

  // Whether today's goal is met
  bool get isGoalMet => todayIntake >= _dailyGoalMl;

  // Remaining ml for today
  int get remainingMl => (_dailyGoalMl - todayIntake).clamp(0, _dailyGoalMl);

  // Current streak (consecutive days where goal was met)
  int get currentStreak {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    // If goal not met today, start from yesterday
    if (!isGoalMet) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dayTotal = getIntakeForDate(checkDate);
      if (dayTotal >= _dailyGoalMl) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Get intake for a specific date
  int getIntakeForDate(DateTime date) {
    return _entries
        .where(
          (e) =>
              e.timestamp.year == date.year &&
              e.timestamp.month == date.month &&
              e.timestamp.day == date.day,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }

  // Get entries for a date range
  List<WaterEntry> getEntriesInRange(DateTime start, DateTime end) {
    return _entries.where((e) {
      return e.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
          e.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get daily totals for a range of dates
  Map<DateTime, int> getDailyTotals(DateTime start, DateTime end) {
    final Map<DateTime, int> totals = {};
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      totals[current] = getIntakeForDate(current);
      current = current.add(const Duration(days: 1));
    }
    return totals;
  }

  // Get hourly totals for a specific date
  Map<int, int> getHourlyTotals(DateTime date) {
    final Map<int, int> totals = {};
    for (int i = 0; i < 24; i++) {
      totals[i] = 0;
    }

    final dayEntries = _entries.where(
      (e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day,
    );

    for (final entry in dayEntries) {
      totals[entry.timestamp.hour] =
          (totals[entry.timestamp.hour] ?? 0) + entry.amount;
    }
    return totals;
  }

  // Get monthly totals for a year
  Map<int, int> getMonthlyTotals(int year) {
    final Map<int, int> totals = {};
    for (int i = 1; i <= 12; i++) {
      totals[i] = 0;
    }

    final yearEntries = _entries.where((e) => e.timestamp.year == year);
    for (final entry in yearEntries) {
      totals[entry.timestamp.month] =
          (totals[entry.timestamp.month] ?? 0) + entry.amount;
    }
    return totals;
  }

  // Weekly average
  double get weeklyAverage {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int totalDays = now.weekday;
    int totalIntake = 0;

    for (int i = 0; i < totalDays; i++) {
      totalIntake += getIntakeForDate(weekStart.add(Duration(days: i)));
    }
    return totalDays > 0 ? totalIntake / totalDays : 0;
  }

  // Best day in the last 30 days
  MapEntry<DateTime, int> get bestDay {
    final now = DateTime.now();
    DateTime bestDate = now;
    int bestAmount = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final intake = getIntakeForDate(date);
      if (intake > bestAmount) {
        bestAmount = intake;
        bestDate = date;
      }
    }
    return MapEntry(bestDate, bestAmount);
  }

  // Actions
  Future<void> setSelectedSize(int size) async {
    _selectedSize = size;
    if (!WaterDefaults.presetSizes.contains(size)) {
      _lastCustomSize = size;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedContainerSize', size);
    if (_lastCustomSize != null) {
      await prefs.setInt('lastCustomContainerSize', _lastCustomSize!);
    }
  }

  Future<void> addWater([int? amount]) async {
    final entry = WaterEntry(
      amount: amount ?? _selectedSize,
      timestamp: DateTime.now(),
    );
    _entries.add(entry);
    notifyListeners();
    await _saveEntries();
    _rescheduleNotifications(); // recalculate based on latest drink
  }

  Future<void> removeEntry(WaterEntry entry) async {
    _entries.removeWhere(
      (e) => e.timestamp == entry.timestamp && e.amount == entry.amount,
    );
    notifyListeners();
    await _saveEntries();
    _rescheduleNotifications();
  }

  Future<void> undoLastEntry() async {
    final today = todayEntries;
    if (today.isNotEmpty) {
      final last = today.first; // already sorted descending
      await removeEntry(last);
    }
  }

  Future<void> setDailyGoal(int goalMl) async {
    _dailyGoalMl = goalMl;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', goalMl);
  }

  // Profile actions
  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await _saveProfile();
    _rescheduleNotifications();
  }

  Future<void> completeOnboarding({
    required String name,
    required MeasureUnit unit,
    required WeightUnit weightUnit,
    required HeightUnit heightUnit,
    required double heightCm,
    required double weightKg,
    required int age,
    required String wakeTime,
    required String sleepTime,
    required int dailyGoalMl,
    required Gender gender,
  }) async {
    _profile = UserProfile(
      name: name,
      unit: unit,
      weightUnit: weightUnit,
      heightUnit: heightUnit,
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      onboardingComplete: true,
      gender: gender,
    );
    _dailyGoalMl = dailyGoalMl;
    notifyListeners();
    await _saveProfile();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', dailyGoalMl);
    _rescheduleNotifications();
  }

  // Reminder mode & custom alarms actions
  Future<void> setReminderMode(ReminderMode mode) async {
    if (_profile.reminderMode == mode) return;
    _profile = _profile.copyWith(reminderMode: mode);
    notifyListeners();
    await _saveProfile();
    await _rescheduleNotifications();
  }

  Future<void> _saveCustomAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _customAlarms.map((a) => a.toJson()).toList();
    await prefs.setString('customReminderAlarms', jsonEncode(jsonList));
  }

  Future<void> toggleAlarm(String id) async {
    final idx = _customAlarms.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final updated = _customAlarms[idx].copyWith(
        isEnabled: !_customAlarms[idx].isEnabled,
      );
      _customAlarms[idx] = updated;
      notifyListeners();
      await _saveCustomAlarms();
      await _rescheduleNotifications();
    }
  }

  Future<void> updateAlarm(ReminderAlarm alarm) async {
    final idx = _customAlarms.indexWhere((a) => a.id == alarm.id);
    if (idx != -1) {
      _customAlarms[idx] = alarm;
      _sortAlarms();
      notifyListeners();
      await _saveCustomAlarms();
      await _rescheduleNotifications();
    }
  }

  Future<void> addAlarm(String time, {List<int>? days}) async {
    final newAlarm = ReminderAlarm(
      id: 'alarm_${DateTime.now().millisecondsSinceEpoch}',
      time: time,
      isEnabled: true,
      days: days ?? const [1, 2, 3, 4, 5, 6, 7],
    );
    _customAlarms.add(newAlarm);
    _sortAlarms();
    notifyListeners();
    await _saveCustomAlarms();
    await _rescheduleNotifications();
  }

  Future<void> deleteAlarm(String id) async {
    _customAlarms.removeWhere((a) => a.id == id);
    notifyListeners();
    await _saveCustomAlarms();
    await _rescheduleNotifications();
  }

  Future<void> deleteAlarms(List<String> ids) async {
    final set = ids.toSet();
    _customAlarms.removeWhere((a) => set.contains(a.id));
    notifyListeners();
    await _saveCustomAlarms();
    await _rescheduleNotifications();
  }

  Future<void> deleteAllAlarms() async {
    _customAlarms.clear();
    notifyListeners();
    await _saveCustomAlarms();
    await _rescheduleNotifications();
  }

  Future<void> resetAlarmsToDefault() async {
    _customAlarms = ReminderAlarm.generateDefaultSchedule(
      wakeTime: _profile.wakeTime,
      sleepTime: _profile.sleepTime,
    );
    _sortAlarms();
    notifyListeners();
    await _saveCustomAlarms();
    await _rescheduleNotifications();
  }

  void _sortAlarms() {
    _customAlarms.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
  }

  Future<void> _rescheduleNotifications() async {
    if (!isOnboardingComplete) return;

    final wakeParts = profile.wakeTime.split(':');
    final sleepParts = profile.sleepTime.split(':');
    if (wakeParts.length != 2 || sleepParts.length != 2) return;

    int wakeHour = int.tryParse(wakeParts[0]) ?? 7;
    int wakeMinute = int.tryParse(wakeParts[1]) ?? 0;
    
    int sleepHour = int.tryParse(sleepParts[0]) ?? 23;
    int sleepMinute = int.tryParse(sleepParts[1]) ?? 0;

    final now = DateTime.now();
    DateTime wakeDt = DateTime(now.year, now.month, now.day, wakeHour, wakeMinute);
    DateTime sleepDt = DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
    
    if (sleepDt.isBefore(wakeDt)) {
      sleepDt = sleepDt.add(const Duration(days: 1));
    }

    // Morning cheer calculation
    DateTime nextDayWakeTime = DateTime(now.year, now.month, now.day + 1, wakeHour, wakeMinute);
    DateTime? morningCheerTime;
    if (isGoalMet) {
      morningCheerTime = nextDayWakeTime;
    } else {
      final yesterdayMet = getIntakeForDate(now.subtract(const Duration(days: 1))) >= _dailyGoalMl;
      if (yesterdayMet && now.isBefore(wakeDt)) {
        morningCheerTime = wakeDt;
      }
    }

    // Streak maintain calculation
    DateTime? streakMaintainTime;
    if (!isGoalMet && currentStreak > 0) {
      final warningTime = sleepDt.subtract(const Duration(hours: 2));
      if (warningTime.isAfter(now)) {
        streakMaintainTime = warningTime;
      }
    }

    // Manual schedule mode branch
    if (_profile.reminderMode == ReminderMode.manual) {
      await NotificationService().scheduleManualReminders(
        alarms: _customAlarms,
        morningCheerTime: morningCheerTime,
        streakMaintainTime: streakMaintainTime,
      );
      return;
    }

    // Smart Adaptive mode calculation
    final totalMinutesAwake = sleepDt.difference(wakeDt).inMinutes;
    if (totalMinutesAwake <= 0) return;
    
    final int size = selectedSize > 0 ? selectedSize : 250;
    final int drinksNeeded = (dailyGoalMl / size).ceil();
    if (drinksNeeded <= 0) return;

    final int intervalMinutes = totalMinutesAwake ~/ drinksNeeded;

    // Calculate times for today/tonight based on last drink
    DateTime lastDrinkTime = wakeDt;
    final entries = todayEntries;
    if (entries.isNotEmpty) {
      if (entries.first.timestamp.isAfter(wakeDt)) {
        lastDrinkTime = entries.first.timestamp;
      }
    }

    List<DateTime> scheduledTimes = [];
    DateTime nextTime = lastDrinkTime.add(Duration(minutes: intervalMinutes));
    
    while (nextTime.isBefore(now)) {
      nextTime = nextTime.add(Duration(minutes: intervalMinutes));
    }

    while (nextTime.isBefore(sleepDt)) {
      scheduledTimes.add(nextTime);
      nextTime = nextTime.add(Duration(minutes: intervalMinutes));
    }

    DateTime nextDaySleepTime = DateTime(now.year, now.month, now.day + 1, sleepHour, sleepMinute);
    if (nextDaySleepTime.isBefore(nextDayWakeTime)) {
      nextDaySleepTime = nextDaySleepTime.add(const Duration(days: 1));
    }
    
    DateTime nextDayTime = nextDayWakeTime;
    while (nextDayTime.isBefore(nextDaySleepTime)) {
      scheduledTimes.add(nextDayTime);
      nextDayTime = nextDayTime.add(Duration(minutes: intervalMinutes));
    }

    await NotificationService().scheduleSmartReminders(
      drinkReminders: scheduledTimes,
      morningCheerTime: morningCheerTime,
      streakMaintainTime: streakMaintainTime,
    );
  }

  // Persistence
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoalMl = prefs.getInt('dailyGoal') ?? WaterDefaults.dailyGoalMl;
    final savedSize = prefs.getInt('selectedContainerSize');
    if (savedSize != null && savedSize > 0) {
      _selectedSize = savedSize;
    }
    _lastCustomSize = prefs.getInt('lastCustomContainerSize');

    // Load profile
    final profileJson = prefs.getString('userProfile');
    if (profileJson != null) {
      _profile = UserProfile.fromJson(
        jsonDecode(profileJson) as Map<String, dynamic>,
      );
    }

    final entriesJson = prefs.getString('waterEntries');
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _entries = decoded
          .map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Load custom alarms
    final alarmsJson = prefs.getString('customReminderAlarms');
    if (alarmsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(alarmsJson);
        _customAlarms = decoded
            .map((e) => ReminderAlarm.fromJson(e as Map<String, dynamic>))
            .toList();
        _sortAlarms();
      } catch (_) {
        _customAlarms = ReminderAlarm.generateDefaultSchedule(
          wakeTime: _profile.wakeTime,
          sleepTime: _profile.sleepTime,
        );
      }
    } else {
      _customAlarms = ReminderAlarm.generateDefaultSchedule(
        wakeTime: _profile.wakeTime,
        sleepTime: _profile.sleepTime,
      );
    }

    // Clean up entries older than 1 year to save storage
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    _entries.removeWhere((e) => e.timestamp.isBefore(oneYearAgo));

    _isLoaded = true;
    notifyListeners();
    
    // Reschedule notifications in case time changed
    _rescheduleNotifications();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('waterEntries', encoded);
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', jsonEncode(_profile.toJson()));
  }
}
