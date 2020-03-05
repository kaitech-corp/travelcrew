import 'package:flutter/material.dart';
import 'package:travelcrew/screens/login_screen/login_screen.dart';

class Authenticate extends StatefulWidget{
  @override
  _AuthenticateState createState() => _AuthenticateState();

}
class _AuthenticateState extends State<Authenticate>{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: LoginPage(),

    );
  }
}