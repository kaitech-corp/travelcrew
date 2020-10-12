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
        child: ClipRRect(
          // borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30),),
            child: _assestPath.contains("https") ? Image.network(_assestPath, fit: BoxFit.fill,) : Image.asset(_assestPath,
              fit: BoxFit.cover,
            )
        ),
        );
  }
}

class ImageLayout2 extends StatelessWidget{
  final String _assestPath;

  ImageLayout2(this._assestPath);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: 200.0,
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30),),
          child: _assestPath.contains("https") ? Image.network(_assestPath, fit: BoxFit.fill,) : Image.asset(_assestPath,
            fit: BoxFit.cover,
          )
      ),
    );
  }
}