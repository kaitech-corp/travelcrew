import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travel_crew/models/aeroplanes_model.dart';
import 'package:travel_crew/utils/app_strings.dart';

class AviationStackService {
  /// Function to fetch airport suggestions using AviationStack API
  static Future<List<AeroplanesModel>> fetchAirportSuggestions({
    required String query,
  }) async {
    try {
      final url = Uri.https('api.aviationstack.com', '/v1/airports', {
        'access_key': kAviationStackAccessKey,
        'search': query,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['data'];

        return results.map<AeroplanesModel>((airport) {
          return AeroplanesModel.fromJson(airport);
        }).toList();
      }
    } catch (e) {}
    return [];
  }
}
