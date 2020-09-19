import 'package:flutter/material.dart';
import 'package:travelcrew/screens/menu_screens/help/feedback_page.dart';
import 'package:travelcrew/screens/menu_screens/privacy_policy/privacy_page.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';

class HelpPage extends StatelessWidget{

  Key key1;
  String urlToS = 'https://travelcrewkt.wordpress.com/terms-of-service/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Help & Feedback'),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height *.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 5),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold),),
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Terms of Service'),
                        Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WebViewScreen(urlToS, key1)),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Privacy Policy'),
                        Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                      );
                    },
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 5, bottom: 5),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Feedback',textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold),),
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Provide Feedback'),
                        Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedbackPage()),
                      );
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