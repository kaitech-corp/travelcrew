import 'package:flutter/material.dart';

import 'package:travelcrew/size_config/size_config.dart';

class ReusableThemeColor {
  Color color(BuildContext context){
    return  Colors.white;
  }
  Color colorOpposite(BuildContext context){
    return Colors.black;
  }
  // 212121
  Color cardColor(BuildContext context){
    return Colors.white;
  }

  //Bottom Navigation background color
  Color bottomNavColor(BuildContext context){
    return Colors.blue;
  }

  TextStyle greenOrBlueTextColor(BuildContext context){
    return
    TextStyle(color: Colors.blue,fontSize: 16,fontFamily: 'Cantata One',fontWeight: FontWeight.bold);
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

    return Icon(icon ,color: Colors.black);
  }

}

class SplitIconWidget extends StatelessWidget{

  final String type;

  const SplitIconWidget({Key key, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    switch (type){
      case "Activity":
        return Container(
            height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  [Colors.yellow[100], Colors.yellow[50]],
                    stops: const [0.4,1.0]
                )
            ),
            child: Icon(Icons.directions_bike ,color: Colors.amber.shade600));
      case "Lodging":
        // return CircleAvatar(backgroundColor: Colors.orange,radius: 30,);
        return Container(
          height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  [Colors.orange[100], Colors.orange[50]],
                    stops: const [0.4,1.0]
                )
            ),
            child: Icon(Icons.hotel ,color: Colors.orangeAccent,)
        );
      case "Transportation":
        return Container(
            height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  [Colors.purple[100], Colors.purple[50]],
                    stops: const [0.4,1.0]
                )
            ),
            child: Icon(Icons.flight ,color: Colors.purpleAccent));
      default:
        return Container(
            height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  [Colors.green.shade100, Colors.green.shade50],
                    stops: const [0.4,1.0]
                )
            ),
            child: Icon(Icons.monetization_on ,color: Colors.green));
    }
  }

}

// Icon color for Trip Details
class TripDetailsIconThemeWidget extends StatelessWidget{

  final IconData icon;

  const TripDetailsIconThemeWidget({Key key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: Colors.blue);
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
