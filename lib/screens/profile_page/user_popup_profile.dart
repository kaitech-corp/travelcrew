import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/custom_objects.dart';
import '../../services/constants/constants.dart';

class UserPopupProfile extends StatelessWidget{

  final Members member;

  UserPopupProfile({required this.member});

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
              child: FadeInImage.assetNetwork(placeholder: profileImagePlaceholder, image: member.urlToImage!,height: 300,
                width: 300,)

            ),
          ),
        ),
      ],
    );
  }

}