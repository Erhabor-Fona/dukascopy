import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'models.dart';

const _baseUrl = 'https://freeserv.dukascopy.com/2.0/index.php';

String _randomCallback() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return '_callbacks____${List.generate(9, (_) => chars[rand.nextInt(chars.length)]).join()}';
}

String _stripJsonpPayload(String text) {
  final start = text.indexOf('(');
  final end = text.lastIndexOf(')');
  if (start == -1 || end == -1 || end <= start) {
    return text;
  }
  return text.substring(start + 1, end);
}

/// Fetches the instrument groups from Dukascopy.
Future<Map<String, InstrumentGroup>> fetchInstrumentGroups({
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  final callback = _randomCallback();
  final uri = Uri.parse(_baseUrl).replace(queryParameters: {
    'path': 'common/instruments',
    'jsonp': callback,
  });
  final response = await httpClient.get(uri, headers: {
    'User-Agent': 'dart-http-client',
  });
  final jsonText = _stripJsonpPayload(response.body);
  final data = json.decode(jsonText) as Map<String, dynamic>;
  final groups = <String, InstrumentGroup>{};
  (data['groups'] as Map<String, dynamic>).forEach((key, value) {
    groups[key] = InstrumentGroup.fromJson(value as Map<String, dynamic>);
  });
  return groups;
}
