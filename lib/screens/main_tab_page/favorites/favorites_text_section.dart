import 'package:flutter/material.dart';

class FavoritesTextSection extends StatelessWidget{
  final String _text;

  FavoritesTextSection(this._text);

  @override
  Widget build(BuildContext context) {

    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: _text,
      ),
    );
  }
}