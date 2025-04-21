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

String _stripJsonpPayload(String text, String callback) {
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

/// Fetches the instrument groups from Dukascopy.
Future<Map<String, InstrumentGroup>> fetchInstrumentGroups() async {
  final callback = _randomCallback();
  final uri = Uri.parse(_baseUrl).replace(queryParameters: {
    'path': 'common/instruments',
    'jsonp': callback,
  });
  final response = await http.get(uri, headers: {
    'User-Agent': 'dart-http-client',
  });
  final jsonText = _stripJsonpPayload(response.body, callback);
  final data = json.decode(jsonText) as Map<String, dynamic>;
  final groups = <String, InstrumentGroup>{};
  (data['groups'] as Map<String, dynamic>).forEach((key, value) {
    groups[key] = InstrumentGroup.fromJson(value as Map<String, dynamic>);
  });
  return groups;
}
