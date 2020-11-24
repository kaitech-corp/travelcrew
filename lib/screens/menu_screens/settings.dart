import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';

class Settings extends StatefulWidget{



  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    String theme_id = ThemeProvider.themeOf(context).id;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Settings',style: Theme.of(context).textTheme.headline3,),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          height: SizeConfig.screenHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Theme',style: Theme.of(context).textTheme.headline2,),
              RadioListTile<String>(
                title: const Text('Dark'),
                value: 'dark_theme',
                groupValue: theme_id,
                onChanged: (value) {
                  setState(() {
                    theme_id = value;
                    ThemeProvider.controllerOf(context).setTheme(value);
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Light'),
                value: 'light_theme',
                groupValue: theme_id,
                onChanged: (value) {
                  setState(() {
                    theme_id = value;
                    ThemeProvider.controllerOf(context).setTheme(value);
                  });
                },
              ),
              Container(height: 2, decoration: BoxDecoration(border: Border.all(color: Colors.black12)),),
              Padding(padding: EdgeInsets.only(top: 25)),
              Column(
                children: [
                  Text("Follow us on social media for 'How to' videos and new feature updates!",style: Theme.of(context).textTheme.headline2, textAlign: TextAlign.center,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _instagramButton(),
                        _facbookButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _instagramButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        TCFunctions().launchURL(TC_InstagramPage);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      highlightElevation: 0,
      borderSide: const BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(instagram_logo), height: 25.0),
            Text(' Instagram')
          ],
        ),
      ),
    );
  }
  Widget _facbookButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        TCFunctions().launchURL(TC_FacebookPage);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      highlightElevation: 0,
      borderSide: const BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(facebook_logo), height: 25.0),
            Text(' Facebook')
          ],
        ),
      ),
    );
  }
}