import 'package:flutter/material.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/constants.dart';

class HelpPage extends StatelessWidget{

   final Key key1;

  const HelpPage({Key key, this.key1}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Help & Feedback',style: Theme.of(context).textTheme.headline3,),
        ),
        body: Container(
          margin: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height *.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 5),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',style: Theme.of(context).textTheme.subtitle1,),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
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
                  Text('Feedback',style: Theme.of(context).textTheme.subtitle1,),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
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