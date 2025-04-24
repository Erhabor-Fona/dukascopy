import 'package:dukascopy/dukascopy.dart';

void main() async {
  // Load instrument groups
  final groups = await fetchInstrumentGroups();
  log('Groups: ${groups.keys}');

  // Fetch 5 days of EUR/USD daily data:
  final start = DateTime.utc(2025,1,1);
  final dailyRows = await fetch(
    instrument: 'EUR/USD',
    interval: '1DAY',
    offerSide: 'B',
    lastUpdateMillis: start.millisecondsSinceEpoch,
    limit: 5,
  );
  dailyRows.forEach((row) {
    log('Timestamp=${row[0]}, OHLC=[${row[1]},${row[2]},${row[3]},${row[4]}], vol=${row[5]}');
  });

  // Stream tick data for the next 10 seconds:
  final now = DateTime.now().toUtc();
  await for (final tick in stream(
    instrument: 'EUR/USD',
    interval: 'TICK',
    offerSide: 'B',
    startMillis: now.millisecondsSinceEpoch,
    endMillis: now.add(const Duration(seconds: 10)).millisecondsSinceEpoch,
    limit: 10,
  )) {
    log('Tick @${tick[0]}: bid=${tick[1]}, ask=${tick[2]}');
  }
}
