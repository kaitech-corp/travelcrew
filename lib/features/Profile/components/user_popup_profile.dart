import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../models/member_model/member_model.dart';
import '../../../services/constants/constants.dart';

class UserPopupProfile extends StatelessWidget{

  const UserPopupProfile({Key? key, required this.member}) : super(key: key);

  final MemberModel member;

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
              child: (member.urlToImage.isEmpty) ? Image.network(profileImagePlaceholder) : Image.network(member.urlToImage),

            ),
          ),
        ),
      ],
    );
  }

}
