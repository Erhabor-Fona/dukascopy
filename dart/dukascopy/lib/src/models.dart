class InstrumentGroup {
  final String id;
  final String title;
  final String? parent;
  final List<String> instruments;

  InstrumentGroup({
    required this.id,
    required this.title,
    this.parent,
    required this.instruments,
  });

  factory InstrumentGroup.fromJson(Map<String, dynamic> json) {
    return InstrumentGroup(
      id: json['id'] as String,
      title: json['title'] as String,
      parent: json['parent'] as String?,
      instruments:
          (json['instruments'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
    );
  }
}

class Candle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  
  factory Candle.fromRaw(List<dynamic> row) {
    return Candle(
      timestamp: DateTime.fromMillisecondsSinceEpoch(row[0] as int, isUtc: true),
      open:      (row[1] as num).toDouble(),
      high:      (row[2] as num).toDouble(),
      low:       (row[3] as num).toDouble(),
      close:     (row[4] as num).toDouble(),
      volume:    (row[5] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Candle(timestamp: $timestamp, O:$open H:$high L:$low C:$close V:$volume)';
  }
}
