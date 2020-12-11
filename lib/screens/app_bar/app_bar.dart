import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/reusableWidgets.dart';
import 'package:travelcrew/size_config/size_config.dart';


class CustomAppBar extends StatelessWidget {

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  CustomAppBar({
    Key key, this.bottomNav, this.heroTag,
  }) : super(key: key);
  final heroTag;
  final  bool bottomNav;
  final double hgt = SizeConfig.screenHeight*.06;
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
          height: SizeConfig.screenHeight*.22,
          width: double.infinity,
          decoration: (ThemeProvider.themeOf(context).id == 'light_theme') ?
          BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[900],
                  Colors.lightBlueAccent
                ]
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
              ),
              BoxShadow(
                color: Colors.blueAccent,
                blurRadius: 10.0,
              ),
            ],
          ): BoxDecoration(
              image: DecorationImage(
                image: AssetImage(spaceImage),
                fit: BoxFit.cover,
              )),
          child: Padding(
              padding: EdgeInsets.fromLTRB(8.0,0,8.0,0),
              child:
              Stack(
                children: [
                  Positioned.fill(
                    top: 0,
                    child: AppBar(
                      shadowColor: Color(0x00000000),
                      backgroundColor: Color(0x00000000),
                      actions: <Widget>[
                        Center(
                          child: InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, '/profilePage');
                            },
                            child: Hero(
                              tag: currentUserProfile?.uid ?? '1234',
                              transitionOnUserGestures: true,
                              child: CircleAvatar(
                                radius: SizeConfig.screenWidth/8.0,
                                backgroundImage: (currentUserProfile?.urlToImage?.isNotEmpty ?? false) ? NetworkImage(currentUserProfile.urlToImage,) : AssetImage(profileImagePlaceholder),
                              ),
                            ),
                          ),
                        ),
                        // SizedBox(width: SizeConfig.screenWidth/16.0,),
                        IconButton(
                          icon: const Icon(Icons.chat),
                          onPressed: (){
                            Navigator.pushNamed(context, '/chats_page');
                          },
                        ),
                        // SizedBox(width: SizeConfig.screenWidth/16.0,),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: (){
                            Navigator.pushNamed(context, '/addTrip');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                overflow: Overflow.visible,
              )
          )
      ),
    );
  }
}