import 'package:flutter/material.dart';

class ImageLayout extends StatelessWidget{
  final String _assestPath;

  ImageLayout(this._assestPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(
          height: 200.0,
        ),
        decoration: BoxDecoration(color: Colors.white),
        child: _assestPath?.contains("https") ? Image.network(_assestPath, fit: BoxFit.fill,) : Image.asset(_assestPath,
          fit: BoxFit.fill,
        ));
  }
}