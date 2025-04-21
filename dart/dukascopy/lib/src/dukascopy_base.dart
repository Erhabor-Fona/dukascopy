import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

const _chartUrl = 'https://freeserv.dukascopy.com/2.0/index.php';
const _defaultHeaders = {
  'User-Agent': 'dart-http-client',
  'Host': 'freeserv.dukascopy.com',
  'Referer': 'https://freeserv.dukascopy.com/2.0/?path=chart/index',
};

String _randomCallback() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return '_callbacks____${List.generate(9, (_) => chars[rand.nextInt(chars.length)]).join()}';
}

String _stripJsonp(String text, String callback) {
  final prefix = '$callback(';
  final suffix = ');';
  var result = text;
  if (result.startsWith(prefix)) {
    result = result.substring(prefix.length);
  }
  if (result.endsWith(suffix)) {
    result = result.substring(0, result.length - suffix.length);
  }
  return result;
}

/// Fetch the instrument groups from Dukascopy.
/// Fetch raw chart data as a list of rows.
Future<List<List<dynamic>>> fetch({
  required String instrument,
  required String interval,
  required String offerSide,
  required int lastUpdateMillis,
  int? limit,
}) async {
  final callback = _randomCallback();
  final params = {
    'path': 'chart/json3',
    'splits': 'true',
    'stocks': 'true',
    'time_direction': 'N',
    'jsonp': callback,
    'last_update': lastUpdateMillis.toString(),
    'offer_side': offerSide,
    'instrument': instrument,
    'interval': interval,
    if (limit != null) 'limit': limit.toString(),
  };
  final uri = Uri.parse(_chartUrl).replace(queryParameters: params);
  final response = await http.get(uri, headers: _defaultHeaders);
  final jsonText = _stripJsonp(response.body, callback);
  final raw = json.decode(jsonText) as List<dynamic>;
  return raw.map((e) => (e as List<dynamic>).toList()).toList();
}

/// Streams chart data continuously until [endMillis] is reached.
Stream<List<dynamic>> stream({
  required String instrument,
  required String interval,
  required String offerSide,
  required int startMillis,
  int? endMillis,
  int maxRetries = 7,
  int? limit,
}) async* {
  var retries = 0;
  var cursor = startMillis;
  var first = true;

  while (true) {
    try {
      final updates = await fetch(
        instrument: instrument,
        interval: interval,
        offerSide: offerSide,
        lastUpdateMillis: cursor,
        limit: limit,
      );
      if (!first && updates.isNotEmpty && updates[0][0] == cursor) {
        updates.removeAt(0);
      }
      if (updates.isEmpty) {
        if (endMillis != null) break;
        continue;
      }
      for (final row in updates) {
        final timestamp = row[0] as int;
        if (endMillis != null && timestamp > endMillis) return;
        yield row;
        cursor = timestamp;
      }
      retries = 0;
      first = false;
    } catch (_) {
      if (++retries > maxRetries) rethrow;
      await Future.delayed(Duration(seconds: 1));
    }
  }
}