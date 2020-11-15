import 'package:flutter/material.dart';

class ImageLayout extends StatelessWidget{
  final String _assetPath;

  ImageLayout(this._assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(
          height: 200.0,
        ),
        child: ClipRRect(
          // borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30),),
            child: _assetPath.contains("https") ? Image.network(_assetPath, fit: BoxFit.fill,) : Image.asset(_assetPath,
              fit: BoxFit.cover,
            )
        ),
        );
  }
}

class ImageLayout2 extends StatelessWidget{
  final String _assetPath;

  ImageLayout2(this._assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(
        height: 200.0,
      ),
      child: ClipRRect(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30),),
          child: _assetPath.contains("https") ? FadeInImage.assetNetwork(
            placeholder: 'assets/images/travelPics.png',
            image: _assetPath, fit: BoxFit.cover,) : Image.asset(_assetPath,
            fit: BoxFit.cover,
          )
      ),
    );
  }
}