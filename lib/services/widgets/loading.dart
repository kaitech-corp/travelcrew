import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/size_config/size_config.dart';

class Loading extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black,
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