class WaterEntry {
  final int amount; // in ml
  final DateTime timestamp;

  WaterEntry({
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        amount: json['amount'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
