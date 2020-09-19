import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/locator.dart';
import 'models/custom_objects.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(TravelCrew());
}

class TravelCrew extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
