import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';

class UserPopupProfile extends StatelessWidget{

  final Members member;

  UserPopupProfile({this.member});

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
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: member.urlToImage.isNotEmpty ? NetworkImage(member.urlToImage) : Image.asset(
                'assets/images/travelPics.png',
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