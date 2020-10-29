import 'package:flutter/material.dart';

class ImageBanner extends StatelessWidget{
  final String _assetPath;

  ImageBanner(this._assetPath);

@override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(
        height: 275.0,
      ),
      decoration: const BoxDecoration(color: Colors.grey),
      child: Image.asset(_assetPath,
      fit: BoxFit.cover,
    ));
  }
}