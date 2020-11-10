import 'package:flutter/material.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/constants.dart';

class HelpPage extends StatelessWidget{

  Key key1;

 @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Help & Feedback',style: Theme.of(context).textTheme.headline3,),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height *.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 5),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About',textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold),),
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Terms of Service'),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WebViewScreen(urlToTerms, key1)),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Privacy Policy'),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WebViewScreen(urlToPrivacyPolicy, key1))
                      );
                    },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 5, bottom: 5),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Feedback',textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold),),
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Provide Feedback'),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      Navigator.pushNamed(context, '/feedback');
                    },
                  ),
                ],
              )
            ],
          ),
        )
    );
  }

}