import 'package:dukascopy/dukascopy.dart';

Future<void> main() async {
  // 1. Fetch and print groups
  final groups = await fetchInstrumentGroups();
  print('Available instrument groups:');
  groups.forEach((key, group) {
    print('  $key -> ${group.title} (${group.instruments.length} instruments)');
  });

  // 2. Fetch a batch of daily EUR/USD data
  final start = DateTime.utc(2025, 1, 1);
  final dailyRows = await fetch(
    instrument: 'EUR/USD',
    interval: '1DAY',
    offerSide: 'B',
    lastUpdateMillis: start.millisecondsSinceEpoch,
    limit: 5,
  );
  print('\nEUR/USD Daily Data (first 5 rows):');
  for (var row in dailyRows) {
    final ts = DateTime.fromMillisecondsSinceEpoch(row[0] as int, isUtc: true);
    print('  $ts -> OHLC: [${row[1]}, ${row[2]}, ${row[3]}, ${row[4]}], vol=${row[5]}');
  }

  // 3. Stream ticks for 10 seconds
  print('\nStreaming ticks for 10 seconds...');
  final now = DateTime.now().toUtc();
  final tickStream = stream(
    instrument: 'EUR/USD',
    interval: 'TICK',
    offerSide: 'B',
    startMillis: now.millisecondsSinceEpoch,
    endMillis: now.add(const Duration(seconds: 10)).millisecondsSinceEpoch,
    limit: 10,
  );
  await for (final tick in tickStream) {
    print('  Tick: timestamp=${tick[0]}, bid=${tick[1]}, ask=${tick[2]}');
  }
}