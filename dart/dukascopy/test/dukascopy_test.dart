import 'package:dukascopy/dukascopy.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('Dukascopy API', () {
    test('fetchInstrumentGroups parses JSONP correctly', () async {
      const callback = '_callbacks____TESTCB';

      const payload =
          '{"groups":{"FX":{"id":"FX","title":"Forex","instruments":["EUR/USD"]}}}';

      final body = '$callback($payload);';
      final mockClient = MockClient((_) async => http.Response(body, 200));

      final groups = await fetchInstrumentGroups(client: mockClient);
      expect(groups, isNotEmpty);
      expect(groups['FX']?.title, equals('Forex'));
      expect(groups['FX']?.instruments, contains('EUR/USD'));
    });

    test('fetch returns parsed rows from JSONP', () async {
      const callback = '_callbacks____TESTCB2';
      // A single OHLC row: [timestamp, open, high, low, close, volume]
      final row = [1625097600000, 1.10, 1.15, 1.05, 1.12, 1234];
      final payload = json.encode([row]);
      final body = '$callback($payload);';
      final mockClient = MockClient((_) async => http.Response(body, 200));

      final rows = await fetch(
        instrument: 'EUR/USD',
        interval: '1DAY',
        offerSide: 'B',
        lastUpdateMillis: 0,
        limit: 1,
        client: mockClient,
      );
      expect(rows, hasLength(1));
      expect(rows.first, equals(row));
    });

    test('stream yields rows until endMillis', () async {
      const callback = '_callbacks____STREAMCB';
      final rowsA = [
        [1000, 1, 2, 3, 4, 5],
        [2000, 6, 7, 8, 9, 10],
      ];
      final payloadA = json.encode(rowsA);
      final bodyA = '$callback($payloadA);';

      // After first call, return an empty list to break
      final mockClient = MockClient((_) async {
        return http.Response(bodyA, 200);
      });

      final results = <List<dynamic>>[];
      await for (final r in stream(
        instrument: 'EUR/USD',
        interval: '1DAY',
        offerSide: 'B',
        startMillis: 0,
        endMillis: 3000,
        limit: 2,
        client: mockClient,
      )) {
        results.add(r);
      }
      expect(results, equals(rowsA));
    });
  });

}

