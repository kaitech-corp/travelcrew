
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/custom_objects.dart';

class WalmartProductSearch {
  // API key
   late final String? apiKey = dotenv.env['rapidAPIKey'];
  // Base API url
  static const String _baseUrl = 'https://walmart.p.rapidapi.com/v2/auto-complete?term=';
  // Base headers for Response url


  // Base API request to get response
  Future<List<WalmartProducts>> getProducts(String name) async {

    final Map<String, String> headers = <String, String>{
//    "content-type": "application/json",
    'x-rapidapi-host': 'walmart.p.rapidapi.com',
    'x-rapidapi-key': apiKey!,
    };

//    Uri uri = Uri.https(_baseUrl, endpoint);
    final http.Response response = await http.get(Uri.parse('$_baseUrl + $name'), headers: headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      final dynamic result = json.decode(response.body);
      final Iterable<dynamic> list = result['queries'] as Iterable<dynamic>;
      return list.map((dynamic stat) => WalmartProducts.fromJSON(stat as Map<String, dynamic>)).toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data: ${response.statusCode}');
    }
  }
}

