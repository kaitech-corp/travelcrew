import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchModel {
  const SearchModel({
    this.views,
    this.placeId,
    this.latLng,
    this.imageUrl,
    required this.searchText,
  });
  final String? views;
  final String searchText;
  final String? imageUrl;
  final String? placeId;
  final LatLng? latLng;
}
