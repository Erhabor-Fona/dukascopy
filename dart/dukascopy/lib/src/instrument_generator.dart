import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'models.dart';

const _baseUrl = 'https://freeserv.dukascopy.com/2.0/index.php';

String _randomCallback() {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
  final url = '$_baseUrl?path=common/instruments&jsonp=$callback';
  dev.log('object ==> $url');
  final response = await httpClient.get(Uri.parse(url), headers: {
    'User-Agent': 'dart-http-client',
    'Referer':
        'https://freeserv.dukascopy.com/2.0/?path=chart/index&showUI=true&showTabs=true&showParameterToolbar=true&showOfferSide=true&allowInstrumentChange=true&allowPeriodChange=true&allowOfferSideChange=true&showAdditionalToolbar=true&showExportImportWorkspace=true&allowSocialSharing=true&showUndoRedoButtons=true&showDetachButton=true&presentationType=candle&axisX=true&axisY=true&legend=true&timeline=true&showDateSeparators=true&showZoom=true&showScrollButtons=true&showAutoShiftButton=true&crosshair=true&borders=false&freeMode=false&theme=Pastelle&uiColor=%23000&availableInstruments=l%3A&instrument=EUR/USD&period=5&offerSide=BID&timezone=0&live=true&allowPan=true&width=100%25&height=700&adv=popup&lang=en',
  });
  dev.log('Object Response ==> ${response.body}');
  final jsonText = _stripJsonpPayload(response.body);
  final data = json.decode(jsonText) as Map<String, dynamic>;
  final groups = <String, InstrumentGroup>{};
  (data['groups'] as Map<String, dynamic>).forEach((key, value) {
    groups[key] = InstrumentGroup.fromJson(value as Map<String, dynamic>);
  });
  return groups;
}
