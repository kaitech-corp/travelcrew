import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../repositories/notification_repository.dart';
import '../../screens/authenticate/profile_stream.dart';
import '../database.dart';



class LaunchIconBadger extends StatefulWidget{


  const LaunchIconBadger({Key? key,}) : super(key: key);
  @override
  _LaunchIconBadgerState createState() => _LaunchIconBadgerState();

}
class _LaunchIconBadgerState extends State<LaunchIconBadger> {

    String _appBadgeSupported = 'Unknown';

    @override
    initState() {
      super.initState();
      initPlatformState();

    }

    Future<void> initPlatformState() async {
      String appBadgeSupported;
      try {
        final bool res = await FlutterAppBadger.isAppBadgeSupported();
        if (res) {
          appBadgeSupported = 'Supported';
        } else {
          appBadgeSupported = 'Not supported';
        }
      } on PlatformException {
        appBadgeSupported = 'Failed to get badge support.';
      }
      if (!mounted) return;
      setState(() {
        _appBadgeSupported = appBadgeSupported;
      });
    }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
        create: (BuildContext context){
          return NotificationBloc(notificationRepository: NotificationRepository()..refresh());},
        child: ProfileStream(uid: userService.currentUserID),
    );
  }

  }


