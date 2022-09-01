import 'package:flutter/material.dart';

class SearchBarStyle {

  const SearchBarStyle({
    this.backgroundColor = const Color.fromRGBO(142, 142, 147, .15),
    this.padding = const EdgeInsets.all(5.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(5.0)),
    this.border = const Border(top: _borderSide, bottom: _borderSide, left: _borderSide, right: _borderSide),
    this.height = 42.0,
  });
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Border border;
  final double height;

  static const BorderSide _borderSide = BorderSide(
      color: Color(0xffdcdcdc),
      width: 1.0
  );
}