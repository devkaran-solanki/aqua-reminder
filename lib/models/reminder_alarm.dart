enum ReminderMode {
  auto,
  manual,
}

/// Model representing an individual hydration reminder alarm
class ReminderAlarm {
  final String id;
  final String time; // "HH:mm" in 24-hour format
  final bool isEnabled;
  final List<int> days; // 1 = Monday, 7 = Sunday (matching DateTime.monday..DateTime.sunday)

  const ReminderAlarm({
    required this.id,
    required this.time,
    this.isEnabled = true,
    this.days = const [1, 2, 3, 4, 5, 6, 7],
  });

  ReminderAlarm copyWith({
    String? id,
    String? time,
    bool? isEnabled,
    List<int>? days,
  }) {
    return ReminderAlarm(
      id: id ?? this.id,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'isEnabled': isEnabled,
      'days': days,
    };
  }

  factory ReminderAlarm.fromJson(Map<String, dynamic> json) {
    return ReminderAlarm(
      id: json['id'] as String,
      time: json['time'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
    );
  }

  /// Hour component (0-23)
  int get hour {
    final parts = time.split(':');
    return parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
  }

  /// Minute component (0-59)
  int get minute {
    final parts = time.split(':');
    return parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  }

  /// Total minutes from midnight for sorting
  int get totalMinutes => hour * 60 + minute;

  /// Formatted 12-hour string (e.g. "06:00")
  String get formattedHourMinute {
    final h = hour;
    final m = minute;
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Formatted period in lowercase ("am" / "pm")
  String get amPm => hour >= 12 ? 'pm' : 'am';

  /// Human-readable repetition summary
  String get repetitionSummary {
    if (days.length == 7) return 'Everyday';
    if (days.isEmpty) return 'Never';
    if (days.length == 5 &&
        days.contains(1) &&
        days.contains(2) &&
        days.contains(3) &&
        days.contains(4) &&
        days.contains(5)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Weekends';
    }

    const dayLabels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };

    final sorted = List<int>.from(days)..sort();
    return sorted.map((d) => dayLabels[d] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  /// Generate default preset list of alarms spaced by 90 minutes (1.5 hours) from wake to sleep
  static List<ReminderAlarm> generateDefaultSchedule({
    required String wakeTime,
    required String sleepTime,
  }) {
    final wakeParts = wakeTime.split(':');
    final sleepParts = sleepTime.split(':');
    final wakeH = wakeParts.isNotEmpty ? int.tryParse(wakeParts[0]) ?? 7 : 7;
    final wakeM = wakeParts.length > 1 ? int.tryParse(wakeParts[1]) ?? 0 : 0;
    final sleepH = sleepParts.isNotEmpty ? int.tryParse(sleepParts[0]) ?? 23 : 23;
    final sleepM = sleepParts.length > 1 ? int.tryParse(sleepParts[1]) ?? 0 : 0;

    final wakeMinutes = wakeH * 60 + wakeM;
    var sleepMinutes = sleepH * 60 + sleepM;
    if (sleepMinutes <= wakeMinutes) {
      sleepMinutes += 1440; // overnight handling
    }

    final totalAwake = sleepMinutes - wakeMinutes;
    final List<ReminderAlarm> alarms = [];
    int offset = 0;
    int index = 0;

    while (offset <= totalAwake - 30) {
      final currentTotal = (wakeMinutes + offset) % 1440;
      final h = (currentTotal ~/ 60).toString().padLeft(2, '0');
      final m = (currentTotal % 60).toString().padLeft(2, '0');
      alarms.add(
        ReminderAlarm(
          id: 'alarm_${DateTime.now().millisecondsSinceEpoch}_$index',
          time: '$h:$m',
          isEnabled: true,
          days: const [1, 2, 3, 4, 5, 6, 7],
        ),
      );
      offset += 90; // 1.5 hours
      index++;
    }

    return alarms;
  }
}

