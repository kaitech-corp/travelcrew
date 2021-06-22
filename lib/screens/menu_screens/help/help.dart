import 'package:flutter/material.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/navigation/route_names.dart';

class HelpPage extends StatelessWidget{

  const HelpPage({Key key}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Help & Feedback',style: Theme.of(context).textTheme.headline5,),
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
                  ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Terms of Service'),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      TCFunctions().launchURL(urlToTerms);
                    },
                  ),
                  ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Privacy Policy'),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      TCFunctions().launchURL(urlToPrivacyPolicy);
                      },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 5, bottom: 5),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Feedback',style: Theme.of(context).textTheme.subtitle1,),
                  ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Provide Feedback'),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      navigationService.navigateTo(FeedbackPageRoute);
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