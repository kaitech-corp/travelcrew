import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            Intl.message('Help & Feedback'),
            style: titleLarge(context),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * .5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Intl.message('About'),
                        style: headlineSmall(context),
                      ),
                      Container(
                          height: 2,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.defaultPadding,
                  ),
                  ElevatedButton(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Terms of Service'),
                        Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: () {
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
                    onPressed: () {
                      TCFunctions().launchURL(urlToPrivacyPolicy);
                    },
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.defaultPadding * 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Intl.message('Feedback'),
                        style: headlineSmall(context),
                      ),
                      Container(
                          height: 2,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.defaultPadding,
                  ),
                  ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(Intl.message('Provide Feedback')),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                    onPressed: () {
                      navigationService.navigateTo(FeedbackPageRoute);
                    },
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
