import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/theme/text_styles.dart';

class HelpPage extends StatelessWidget{

  const HelpPage({Key? key}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(Intl.message('Help & Feedback'),style: headlineSmall(context),),
        ),
        body: Container(
          margin: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height *.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 5),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(Intl.message('About'),style: titleMedium(context),),
                  ElevatedButton(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Terms of Service'),
                        Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: (){
                      TCFunctions().launchURL(urlToTerms);
                    },
                  ),
                  ElevatedButton(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Privacy Policy'),
                        Icon(Icons.navigate_next),
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
                children: <Widget>[
                  Text(Intl.message('Feedback'),style: titleMedium(context),),
                  ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(Intl.message('Provide Feedback')),
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
