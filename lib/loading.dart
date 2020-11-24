import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Center(
        child: SpinKitChasingDots(
          color: Colors.blue,
          size: 50.0,
          duration: Duration(seconds: 5),
        ),
      ),
    );
  }
}