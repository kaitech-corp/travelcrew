import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/reusableWidgets.dart';
import 'package:travelcrew/size_config/size_config.dart';


class CustomAppBar extends StatelessWidget {


  final  bool bottomNav;

  CustomAppBar({
    Key key, this.bottomNav,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
          height: SizeConfig.screenHeight*.22,
          width: double.infinity,
          decoration: BoxDecoration(
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
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0,0,8.0,0),
              child:
              Stack(
                children: [
                  Positioned.fill(
                    top: 0,
                    child: AppBar(
                      toolbarHeight: SizerUtil.deviceType == DeviceType.tablet ? SizeConfig.screenHeight*.1 : SizeConfig.screenHeight*.075,
                      shadowColor: const Color(0x00000000),
                      backgroundColor: const Color(0x00000000),
                      actions: <Widget>[
                        Center(
                          child: InkWell(
                            onTap: (){
                              navigationService.navigateTo(ProfilePageRoute);
                            },
                            child: Hero(
                              tag: userService.currentUserID,
                              transitionOnUserGestures: true,
                              child: CircleAvatar(
                                radius: SizeConfig.screenWidth/8.0,
                                backgroundImage: (urlToImage.value.isNotEmpty ?? false) ?
                                NetworkImage(urlToImage.value,) :
                                AssetImage(profileImagePlaceholder),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: AppBarIconThemeWidget(icon: Icons.chat,),
                          onPressed: (){
                            navigationService.navigateTo(DMChatListPageRoute);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                clipBehavior: Clip.none,
              )
          )
      ),
    );
  }
}