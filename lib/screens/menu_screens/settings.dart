import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
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
          height: SizeConfig.screenHeight *.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Container(height: 2, decoration: BoxDecoration(border: Border.all(color: Colors.black12)),)
            ],
          ),
        ),
      ),
    );
  }
}