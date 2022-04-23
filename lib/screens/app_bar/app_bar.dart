import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:travelcrew/blocs/current_profile_bloc/current_profile_bloc.dart';
import 'package:travelcrew/blocs/current_profile_bloc/current_profile_event.dart';
import 'package:travelcrew/blocs/current_profile_bloc/current_profile_state.dart';

import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/reusableWidgets.dart';
import '../../size_config/size_config.dart';

/// Custom app bar
class CustomAppBar extends StatefulWidget {

  final bool bottomNav;

  const CustomAppBar({
    Key key, this.bottomNav,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  CurrentProfileBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<CurrentProfileBloc>(context);
    bloc.add(LoadingCurrentProfileData());
    super.initState();
  }
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
                  Colors.blue.shade900,
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
                      child: BlocBuilder<CurrentProfileBloc, CurrentProfileState>(
                        builder: (context, state){
                          if(state is CurrentProfileLoadingState){
                            return Hero(
                              tag: userService.currentUserID,
                              transitionOnUserGestures: true,
                              child: CircleAvatar(
                                radius: SizeConfig.screenWidth/8.0,
                                backgroundImage: AssetImage(profileImagePlaceholder),
                              ),
                            );
                          } else if (state is CurrentProfileHasDataState){
                            return Hero(
                              tag: userService.currentUserID,
                              transitionOnUserGestures: true,
                              child: CircleAvatar(
                                radius: SizeConfig.screenWidth/8.0,
                                backgroundImage: NetworkImage(state.data.urlToImage,) ,
                              ),
                            );
                          } else {
                            return Hero(
                              tag: userService.currentUserID,
                              transitionOnUserGestures: true,
                              child: CircleAvatar(
                                radius: SizeConfig.screenWidth/8.0,
                                backgroundImage: AssetImage(profileImagePlaceholder),
                              ),
                            );
                          }
                        },
                        // child:
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const AppBarIconThemeWidget(icon: Icons.chat,),
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