import 'package:flutter/material.dart';
import '../../size_config/size_config.dart';
import '../theme/text_styles.dart';

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
    const TextStyle(color: Colors.blue,fontSize: 16,fontFamily: 'Cantata One',fontWeight: FontWeight.bold);
  }
}

class IconThemeWidget extends StatelessWidget{

  const IconThemeWidget({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: Colors.black, size: 30,);
  }

}

class AppBarIconThemeWidget extends StatelessWidget{

  const AppBarIconThemeWidget({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: Colors.black);
  }

}

class SplitIconWidget extends StatelessWidget{

  const SplitIconWidget({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {

    switch (type){
      case 'Activity':
        return Container(
            height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  <Color>[Colors.yellow[100]!, Colors.yellow[50]!],
                    stops: const <double>[0.4,1.0]
                )
            ),
            child: Icon(Icons.directions_bike ,color: Colors.amber.shade600));
      case 'Lodging':
        // return CircleAvatar(backgroundColor: Colors.orange,radius: 30,);
        return Container(
          height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  <Color>[Colors.orange[100]!, Colors.orange[50]!],
                    stops: const <double>[0.4,1.0]
                )
            ),
            child: const Icon(Icons.hotel ,color: Colors.orangeAccent,)
        );
      case 'Transportation':
        return Container(
            height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  <Color>[Colors.purple[100]!, Colors.purple[50]!],
                    stops: const <double>[0.4,1.0]
                )
            ),
            child: const Icon(Icons.flight ,color: Colors.purpleAccent));
      default:
        return Container(
            height: SizeConfig.screenWidth*.2,
            width: SizeConfig.screenWidth*.2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // radius: 15,
                    colors:  <Color>[Colors.green.shade100, Colors.green.shade50],
                    stops: const <double>[0.4,1.0]
                )
            ),
            child: const Icon(Icons.monetization_on ,color: Colors.green));
    }
  }

}

// Icon color for Trip Details
class TripDetailsIconThemeWidget extends StatelessWidget{

  const TripDetailsIconThemeWidget({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {

    return Icon(icon ,color: Colors.blue);
  }

}

class ChatTextStyle {

  TextStyle messageStyle(){
    return const TextStyle(fontFamily: 'Cantata One', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black);
  }

  TextStyle timestampStyle(){
    return const TextStyle(fontFamily: 'Cantata One', fontWeight: FontWeight.normal, fontStyle: FontStyle.italic, fontSize: 14, color: Colors.black);
  }
}


class TransportationIcon extends StatelessWidget{

  const TransportationIcon(this.mode, {super.key});
  final String mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 'Driving':
        return const Icon(Icons.drive_eta);
      case 'Carpooling':
        return const Icon(Icons.directions_car_rounded);
      case 'Bike/Scooter':
        return const Icon(Icons.directions_bike);
      case 'Train':
        return const Icon(Icons.directions_railway_sharp);
      case 'Uber/Lift':
        return const Icon(Icons.directions_car_outlined);
      case 'Bus':
        return const Icon(Icons.directions_bus_rounded);
      default:
        return const Icon(Icons.local_airport);
    }
  }
}

TextStyle responsiveTextStyleSuggestions(BuildContext context){
  if (SizeConfig.tablet) {
    return headlineLarge(context)!;
  } else {
    return titleMedium(context)!;
  }
}

TextStyle responsiveTextStyleTopics(BuildContext context){
  if (SizeConfig.tablet) {
    return displayMedium(context)!;
  } else {
    return headlineMedium(context)!;
  }
}
TextStyle responsiveTextStyleTopicsSub(BuildContext context){
  if (SizeConfig.tablet) {
    return headlineLarge(context)!;
  } else {
    return headlineSmall(context)!;
  }
}
