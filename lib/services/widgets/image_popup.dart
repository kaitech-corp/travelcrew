import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travelcrew/services/constants/constants.dart';

class ImagePopup extends StatelessWidget{

  final String imagePath;

  ImagePopup({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Container(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Container(
          height: 300,
          width: 300,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: (imagePath?.isNotEmpty ?? false) ? NetworkImage(imagePath) : Image.asset(
                profileImagePlaceholder,
                height: 300,
                width: 300,
              ),
            ),
          ),
        ),
      ],
    );
  }

}