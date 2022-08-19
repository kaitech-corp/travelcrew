import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/reusableWidgets.dart';
import '../../size_config/size_config.dart';

/// Custom app bar
class CustomAppBar extends StatelessWidget {

  final  bool bottomNav;

  const CustomAppBar({
    Key? key, required this.bottomNav,
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
                  Colors.blue[900]!,
                  Colors.lightBlueAccent
                ]
            ),
            boxShadow: [
              const BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
              ),
              const BoxShadow(
                color: Colors.blueAccent,
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0,0,8.0,0),
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
                          child: FadeInImage.assetNetwork(placeholder: profileImagePlaceholder, image: urlToImage.value, fit: BoxFit.contain,)
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const AppBarIconThemeWidget(icon: Icons.chat),
                    onPressed: (){
                      navigationService.navigateTo(DMChatListPageRoute);
                    },
                  ),
                ],
              )
          )
      ),
    );
  }
}