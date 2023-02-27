import 'package:flutter/material.dart';

import '../../../services/constants/constants.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appbar_gradient.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isSwitched = false;
  bool isLinked = false;
  bool buttonOnePressed = false;
  bool buttonTwoPressed = false;
  bool buttonThreePressed = false;
  final TextEditingController myController = TextEditingController();
  // late UserSettingsBloc _bloc;
  late String accessToken;

  @override
  void initState() {
    // _bloc = BlocProvider.of<UserSettingsBloc>(context);
    // _bloc.add(LoadingUserSettingsData());
    // getAccessToken();
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Settings',
            style: headlineMedium(context),
          ),
          flexibleSpace: const AppBarGradient(),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          height: SizeConfig.screenHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 25)),
              // Text('Notifications',style: Theme.of(context).textTheme.headline6,),
              // Container(
              //     height: 2,
              //     decoration: BoxDecoration(border: Border.all(color: Colors.black),)),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Push Notifications:',style: titleMedium(context),),
              //     FutureBuilder(
              //       future: SettingsNotifications().permissionStatus(),
              //       builder: (context, status){
              //         if(status.hasData){
              //           return Switch(value: status.data, onChanged: (value){
              //             if (value == true) {
              //               DatabaseService().changeDMSettings(value);
              //               DatabaseService().changeTripChatNotificationSettings(value);
              //               DatabaseService().changeTripNotificationSettings(value);
              //               SettingsNotifications().requestPermission();
              //             } else{
              //               TravelCrewAlertDialogs().turnNotificationsOff(context);
              //             }
              //           },
              //             activeTrackColor: Colors.greenAccent,
              //             activeColor: Colors.green,
              //           );
              //         } else {
              //           return Switch(value: isSwitched, onChanged: (value){
              //             setState(() {
              //               isSwitched = value;
              //               if (value == true) {
              //                 SettingsNotifications().requestPermission();
              //               }
              //             });
              //           },
              //             activeTrackColor: Colors.greenAccent,
              //             activeColor: Colors.green,
              //           );
              //         }
              //       },
              //     ),
              //   ],
              // ),
              // Container(height: 20,),
              // BlocBuilder<UserSettingsBloc,UserSettingsState>(
              //     builder: (context, state) {
              //       if(state is UserSettingsLoadingState){
              //         return CustomNotificationWidget(settings: UserNotificationSettingsData().fakerData(),);
              //       } else if(state is UserSettingsHasDataState){
              //         UserNotificationSettingsData settings = state.data;
              //         return CustomNotificationWidget(settings: settings,);
              //       } else{
              //         return nil;
              //       }
              //     }
              // ),
              // Text('Linked Accounts',style: Theme.of(context).textTheme.headline6,),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     Text('Splitwise:',style: titleMedium(context),),
              //     Switch(value: isLinked, onChanged: (value){
              //       var result = CloudFunction().splitwiseAPI();
              //         setState(() {
              //         isLinked = value;
              //         if (value == true) {
              //
              //         }
              //
              //       });
              //       },
              //       activeTrackColor: Colors.greenAccent,
              //       activeColor: Colors.green,
              //     )
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     ElevatedButton(
              //         onPressed: (){
              //           setState(() {
              //             buttonOnePressed = !buttonOnePressed;
              //             print('Button One: $buttonOnePressed');
              //           });
              //         },
              //         child: Text('Get User')),
              //     ElevatedButton(
              //         onPressed: (){
              //           buttonTwoPressed = !buttonTwoPressed;
              //           print('Button Two: $buttonTwoPressed');
              //         },
              //         child: Text('Get Friends')),
              //     ElevatedButton(
              //         onPressed: (){
              //           buttonThreePressed = !buttonThreePressed;
              //           print('Button Three: $buttonThreePressed');
              //         },
              //         child: Text('Connect'))
              //   ],
              // ),
              // if(buttonThreePressed) FutureBuilder(
              //     future: CloudFunction().connectSplitwise(),
              //     builder: (context, response){
              //       if(response.hasData){
              //         String urlLink = response.data;
              //         return ElevatedButton(
              //             onPressed: (){
              //               TCFunctions().launchURL(urlLink);
              //             },
              //             child: Text('Go'));
              //       } else {
              //         return Text('No data');
              //       }
              //     }),
              // if(buttonOnePressed) FutureBuilder(
              //   future: CloudFunction().splitwiseGetCurrentUser(accessToken),
              //     builder: (context, response){
              //     if(response.hasData && response.data.toString().isNotEmpty){
              //       CurrentUserEntity currentUser = CurrentUserEntity.fromJsonMap(response.data);
              //       return Column(
              //         children: [
              //           Text(currentUser.first_name),
              //           Text(currentUser.last_name),
              //           Text(currentUser.email),
              //           Text(currentUser.id.toString()),
              //           Text(currentUser.default_currency),
              //         ],
              //       );
              //     } else {
              //       return Text('No data');
              //     }
              //     }),
              // if(buttonTwoPressed) FutureBuilder(
              //     future: CloudFunction().splitwiseGetFriends(accessToken),
              //     builder: (context, response){
              //       if(response.hasData){
              //         print(response.data[0]['id']);
              //           List<dynamic> friends = response.data;
              //         // return ListView.builder(
              //         //   itemCount: friends.length,
              //         //     itemBuilder: (context, index){
              //             var friend = friends.first;
              //             return ListTile(
              //               title: Text(friend['first_name']),
              //               subtitle: Text(friend['id'].toString()),
              //             );
              //             // });
              //       } else {
              //         return Text('No data');
              //       }
              //     }),
              // SizedBox(height: 20,),
              Center(
                  child: Text(
                'Social',
                style: headlineLarge(context),
              )),
              Container(
                  height: 2,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  "Follow us on social media for 'How to' videos and new feature updates!",
                  style: titleMedium(context),
                  textAlign: TextAlign.center,
                )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Container(height: SizeConfig.screenWidth*.1,),
                  _instagramButton(),
                  // Container(height: SizeConfig.screenWidth*.1,),
                  _facebookButton(),
                  // Container(height: SizeConfig.screenWidth*.1,),
                  _twitterButton(),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                  child: Text(
                'Account',
                style: headlineLarge(context),
              )),
              Container(
                  height: 2,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Delete this account:',
                      style: titleMedium(context),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        TravelCrewAlertDialogs().disableAccount(context);
                      },
                      child: const Text('Delete')),
                ],
              )
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
          children: const <Widget>[
            Image(image: AssetImage(instagram_logo), height: 25.0),
            // Text(' Instagram',style: Theme.of(context).textTheme.subtitle2,)
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
          children: const <Widget>[
            Image(image: AssetImage(facebook_logo), height: 25.0),
            // Text(' Facebook',style: Theme.of(context).textTheme.subtitle2,)
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
          children: const <Widget>[
            Image(image: AssetImage(twitter_logo), height: 25.0),
            // Text(' Twitter',style: Theme.of(context).textTheme.subtitle2,)
          ],
        ),
      ),
    );
  }
}
