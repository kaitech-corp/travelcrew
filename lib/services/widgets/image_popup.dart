import 'dart:ui';

import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ImagePopup extends StatelessWidget{

  const ImagePopup({Key? key, this.imagePath}) : super(key: key);

  final String? imagePath;

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
        SizedBox(
          height: 300,
          width: 300,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child:FadeInImage.assetNetwork(placeholder: profileImagePlaceholder, image: imagePath!,height: 300,
                width: 300,) ,
            ),
          ),
        ),
      ],
    );
  }

}
