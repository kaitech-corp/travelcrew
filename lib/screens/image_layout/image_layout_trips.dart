import 'package:flutter/material.dart';


/// Widget for trip image layout
class ImageLayout extends StatelessWidget{

  const ImageLayout(this._assetPath);
  final String _assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(
        height: 200.0,
      ),
      child: ClipRRect(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30),),
          child: _assetPath.contains('https') ? FadeInImage.assetNetwork(
            placeholder: 'assets/images/travelPics.png',
            image: _assetPath, fit: BoxFit.cover,) : Image.asset(_assetPath,
            fit: BoxFit.cover,
          )
      ),
    );
  }
}