import 'package:flutter/material.dart';
import 'package:travelcrew/services/apis/splitwise.dart';
import 'package:travelcrew/services/apis/splitwise/splitwise_alert.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';

class Settings extends StatefulWidget{

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool isSwitched = false;
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }


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
                  Text('Linked Accounts',style: Theme.of(context).textTheme.headline6,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Splitwise:',style: Theme.of(context).textTheme.subtitle1,),
                      Switch(value: isSwitched, onChanged: (value){
                        setState(() {
                          isSwitched = value;
                          if (value == true) {
                            // var name =  CloudFunction().splitwiseAPI();
                            // splitWiseAPI();
                            // _showDialog(context, name);
                          }

                        });
                        },
                        activeTrackColor: Colors.greenAccent,
                        activeColor: Colors.green,
                      )
                    ],
                  ),
                  Container(height: 20,),
                  // FutureBuilder(
                  //   future: CloudFunction().splitwiseAPI(),
                  //     builder: (context, response){
                  //     if(response.hasData){
                  //       return Text(response.data);
                  //     } else {
                  //       return Text("Nothing");
                  //     }
                  //     }),
                  // Container(height: 20,),
                  Container(
                      height: 2,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black),)),
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
  Future<void> _showDialog(BuildContext context, dynamic name) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Paste verifier token.',),
            // content: Text('You will no longer have access to this Trip'),
            actions: <Widget>[
              TextFormField(
                controller: myController,

              ),
              TextButton(
                child:  Text('$name',),
                onPressed: () {

                  // print(myController.text);
                  // splitWiseAPI(verifier: myController.text);
                  // navigationService.pop();
                },
              ),
            ],
          );
        });}

}