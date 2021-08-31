import 'package:flutter/material.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';

class Settings extends StatefulWidget{

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Settings',style: Theme.of(context).textTheme.headline5,),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          height: SizeConfig.screenHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(padding: EdgeInsets.only(top: 25)),
              Column(
                children: [
                  Center(child: Text("Follow us on social media for 'How to' videos and new feature updates!",style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(height: SizeConfig.screenWidth*.1,),
                        _instagramButton(),
                        Container(height: SizeConfig.screenWidth*.1,),
                        _facebookButton(),
                        Container(height: SizeConfig.screenWidth*.1,),
                        _twitterButton(),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 2,
                decoration: BoxDecoration(border: Border.all(color: Colors.black),)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _instagramButton() {
    return OutlinedButton(
      onPressed: () {
        TCFunctions().launchURL(TC_InstagramPage);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(instagram_logo), height: 25.0),
            Text(' Instagram',style: Theme.of(context).textTheme.subtitle2,)
          ],
        ),
      ),
    );
  }
  Widget _facebookButton() {
    return OutlinedButton(
      onPressed: () {
        TCFunctions().launchURL(TC_FacebookPage);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(facebook_logo), height: 25.0),
            Text(' Facebook',style: Theme.of(context).textTheme.subtitle2,)
          ],
        ),
      ),
    );
  }

  Widget _twitterButton() {
    return OutlinedButton(
      onPressed: () {
        TCFunctions().launchURL(TC_TwitterPage);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(twitter_logo), height: 25.0),
            Text(' Twitter',style: Theme.of(context).textTheme.subtitle2,)
          ],
        ),
      ),
    );
  }
}