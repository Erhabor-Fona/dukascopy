import 'package:dukascopy/dukascopy.dart';
import 'package:test/test.dart';

void main() {
  group('Dukascopy API package', () {
    test('fetchInstrumentGroups returns a non‑empty map with known keys', () async {
      final groups = await fetchInstrumentGroups();
      expect(groups, isNotEmpty, reason: 'Should retrieve at least one group');
      expect(groups.containsKey('FX'), isTrue, reason: '"FX" (Forex) group should be present');
      final fx = groups['FX']!;
      expect(fx.title, equals('Forex'));
      expect(fx.instruments, contains('EUR/USD'));
    });

    test('fetch returns a batch of rows for EUR/USD 1DAY', () async {
      final start = DateTime.utc(2025, 1, 1);
      final lastUpdate = start.millisecondsSinceEpoch;
      final rows = await fetch(
        instrument: 'EUR/USD',
        interval: '1DAY',
        offerSide: 'B',
        lastUpdateMillis: lastUpdate,
        limit: 10,
      );
      expect(rows, isNotEmpty, reason: 'Should fetch at least one data row');
      expect(rows.first, isA<List<dynamic>>());
      // row[0] is timestamp in ms
      final ts = rows.first[0] as int;
      expect(ts, greaterThanOrEqualTo(lastUpdate));
    });

    test('stream emits at least one tick row within a short window', () async {
      final now = DateTime.now().toUtc();
      final startMillis = now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch;
      final endMillis   = now.millisecondsSinceEpoch;

      final tickStream = stream(
        instrument: 'EUR/USD',
        interval: 'TICK',
        offerSide: 'B',
        startMillis: startMillis,
        endMillis: endMillis,
        limit: 5,
      );

      final firstTick = await tickStream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => fail('Expected at least one tick within 5s'),
      );
      expect(firstTick, isA<List<dynamic>>());
      expect(firstTick.length, greaterThanOrEqualTo(2), reason: 'Tick row should have bid & ask');
    });
  });
}
