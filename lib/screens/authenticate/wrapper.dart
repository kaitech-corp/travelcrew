import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/authenticate/authenticate.dart';
import 'package:travelcrew/screens/authenticate/profile_stream.dart';
import 'package:travelcrew/models/custom_objects.dart';

class Wrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);


    if (user == null) {
      return Authenticate();
    } else {
      return ProfileStream();
    }
  }
}