//Flutter widget that that displays a network image but if string is null or empty then display an asset image instead.

import 'package:flutter/material.dart';

class NetworkImageWithAssetFallback extends StatelessWidget {

  const NetworkImageWithAssetFallback({Key? key,
    required this.imageUrl,
    required this.assetImage
  }) : super(key: key);

  final String imageUrl;
  final String assetImage;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        assetImage,
        fit: BoxFit.cover,
      );
    }
  }
}
