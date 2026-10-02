import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travel_crew/models/aeroplanes_model.dart';
import 'package:travel_crew/utils/app_strings_keys.dart';

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
        final List results = data['data'] as List;

        return results.map<AeroplanesModel>((airport) {
          return AeroplanesModel.fromJson(airport as Map<String, dynamic>);
        }).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }
}
