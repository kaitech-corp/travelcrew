
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:travelcrew/models/custom_objects.dart';

class APIService {
  // API key
  static const _api_key = "";
  // Base API url
  static const String _baseUrl = "https://ajayakv-rest-countries-v1.p.rapidapi.com/rest/v1/all";
  // Base headers for Response url
  static const Map<String, String> _headers = {
    "content-type": "application/json",
    "x-rapidapi-host": "ajayakv-rest-countries-v1.p.rapidapi.com",
    "x-rapidapi-key": _api_key,
  };

  // Base API request to get response
  Future<List<Countries>> getCountries() async {
//    Uri uri = Uri.https(_baseUrl, endpoint);
    final response = await http.get(Uri.parse(_baseUrl), headers: _headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      final result = json.decode(response.body);
//      print(response.body);
      Iterable list = result;
//      print(list.map((country) => Countries.fromJSON(country)).toList());
      return list.map((country) => Countries.fromJSON(country)).toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data');
    }
  }
}

class PublicHolidayAPI {
  // API key
  static const _api_key = "";
  // Base API url
  static const String _baseUrl = "https://public-holiday.p.rapidapi.com/";
  // Base headers for Response url
  static const Map<String, String> _headers = {
//    "content-type": "application/json",
    "x-rapidapi-host": "public-holiday.p.rapidapi.com",
    "x-rapidapi-key": _api_key,
  };

  // Base API request to get response
  Future<List<Holiday>> getHolidays(String code) async {
//    Uri uri = Uri.https(_baseUrl, endpoint);
    final response = await http.get(Uri.parse(_baseUrl +'/'+ DateTime.now().year.toString()+'/'+ code), headers: _headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      final result = json.decode(response.body);
     print(response.body);
//    print(result['countries_stat']);
      Iterable list = result;
      return list.map((stat) => Holiday.fromJSON(stat)).toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data: ${response.statusCode}');
    }
  }
}

class RestCountries {
  // API key
  static const _api_key = "";
  // Base API url
  static const String _baseUrl = "https://restcountries-v1.p.rapidapi.com/name/";
  // Base headers for Response url
  static const Map<String, String> _headers = {
    "content-type": "application/json",
    "x-rapidapi-host": "restcountries-v1.p.rapidapi.com",
    "x-rapidapi-key": _api_key,
  };

  // Base API request to get response
  Future<List<Countries>> getCountry( String name) async {
//    Uri uri = Uri.https(_baseUrl, endpoint);
    final response = await http.get(Uri.parse(_baseUrl + name), headers: _headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      final result = json.decode(response.body);
//      print(response.body);
      Iterable list = result;
//      print(list.map((country) => Countries.fromJSON(country)).toList());
      return list.map((country) => Countries.fromJSON(country)).toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data');
    }
  }
}

class WalmartProductSearch {
  // API key
   var _api_key = dotenv.env['rapidAPIKey'];
  // Base API url
  static const String _baseUrl = "https://walmart.p.rapidapi.com/v2/auto-complete?term=";
  // Base headers for Response url


  // Base API request to get response
  Future<List<WalmartProducts>> getProducts(String name) async {

    Map<String, String> _headers = {
//    "content-type": "application/json",
    "x-rapidapi-host": "walmart.p.rapidapi.com",
    "x-rapidapi-key": _api_key,
    };

//    Uri uri = Uri.https(_baseUrl, endpoint);
    final response = await http.get(Uri.parse('$_baseUrl + $name'), headers: _headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      final result = json.decode(response.body);

      print(result);
      Iterable list = result['queries'];
      return list.map((stat) => WalmartProducts.fromJSON(stat)).toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data: ${response.statusCode}');
    }
  }
}

class ImageSearch {


  Future<String> getImage(String item) {
    // const request = require('request');

    var options = {
      'method': 'POST',
      'url': 'https://texttoimage.p.rapidapi.com/image',
      'headers': {
        'content-type': 'application/json',
        'x-rapidapi-key': '',
        'x-rapidapi-host': 'texttoimage.p.rapidapi.com',
        'useQueryString': true
      },
      'body': {'search_text': '$item', 'num_images': 1},
      'json': true
    };

    // final req = http.Request(options, function (error, response, body) {
    // if (error) throw new Error(error);
    //
    // console.log(body);
    // });

  }
}

class PlacesNearby {
  // API key
  static const _api_key = "";

  // Base API url
  static const String _baseUrl = "https://rapidapi.p.rapidapi.com/FindPlacesNearby";

  // Base headers for Response url
  static const Map<String, String> _headers = {
//    "content-type": "application/json",
    "x-rapidapi-host": "trueway-places.p.rapidapi.com",
    "x-rapidapi-key": _api_key,
  };


  // Base API request to get response
  Future<List<TrueWay>> getNearbyPlaces(String place, String lat, String lng) async {

    // "/FindPlacesNearby?location=37.783366%2C-122.402325&type=cafe&radius=150&language=en"

    if(place == 'tourist'){
      place = 'tourist_attraction';
    }
    var query = '?location=${lat.substring(0,9)}%2C${lng.substring(0,9)}&type=$place&radius=10000&language=en';
    print(query);
    final response = await http.get(Uri.parse(_baseUrl + query), headers: _headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      final result = json.decode(response.body);
      Iterable list = result['results'];
      return list.map((item) => TrueWay.fromJSON(item)).toList();
      // print(statistic.length);
      // return statistic;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data: ${response.statusCode}');
    }
  }
}