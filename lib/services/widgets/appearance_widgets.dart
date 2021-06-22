import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/size_config/size_config.dart';

class ReusableThemeColor {
  Color color(BuildContext context){
    return (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Color(0xFF121212);
  }
  Color colorOpposite(BuildContext context){
    return (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.black : Colors.white;
  }
  // 212121
  Color cardColor(BuildContext context){
    return (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Color(0xFF121212);
  }

  //Bottom Navigation background color
  Color bottomNavColor(BuildContext context){
    return (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.blue : Colors.greenAccent;
  }

  TextStyle greenOrBlueTextColor(BuildContext context){
    return (ThemeProvider.themeOf(context).id == 'light_theme') ?
    TextStyle(color: Colors.blue,fontSize: 16,fontFamily: 'Cantata One',fontWeight: FontWeight.bold) : TextStyle(color: Colors.greenAccent,fontSize: 16,fontFamily: 'Cantata One',fontWeight: FontWeight.bold);
  }
}

class IconThemeWidget extends StatelessWidget{

  final IconData icon;

  const IconThemeWidget({Key key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: Theme.of(context).accentIconTheme.color);
  }

}

class AppBarIconThemeWidget extends StatelessWidget{

  final IconData icon;

  const AppBarIconThemeWidget({Key key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.black : Colors.greenAccent);
  }

}

// Icon color for Trip Details
class TripDetailsIconThemeWidget extends StatelessWidget{

  final IconData icon;

  const TripDetailsIconThemeWidget({Key key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.blue : Colors.greenAccent);
  }

}
// Icon Theme for bottom navigation
class BottomNavIconThemeWidget extends StatelessWidget{

  final IconData icon;

  const BottomNavIconThemeWidget({Key key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: Theme.of(context).accentIconTheme.color);
  }

}



class ChatTextStyle {

  TextStyle messageStyle(){
    return TextStyle(fontFamily: 'Cantata One', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black);
  }

  TextStyle timestampStyle(){
    return TextStyle(fontFamily: 'Cantata One', fontWeight: FontWeight.normal, fontStyle: FontStyle.italic, fontSize: 14, color: Colors.black);
  }
}

class CustomTextScaler {

  Text scaleSubtitle1(String _text, BuildContext context){
    if(SizeConfig.tablet) {
      return Text(
        _text,
        style: Theme.of(context).textTheme.subtitle1,
        textScaleFactor: 1.5,
      );
    } else {
      Text(
        _text,
        style: Theme.of(context).textTheme.subtitle1,
      );
    }
  }

  Text scaleSubtitle2(String _text, BuildContext context){
    if(SizeConfig.tablet) {
      return Text(
        _text,
        style: Theme.of(context).textTheme.subtitle2,
        textScaleFactor: 1.5,
      );
    } else {
      Text(
        _text,
        style: Theme.of(context).textTheme.subtitle2,
      );
    }
  }


}