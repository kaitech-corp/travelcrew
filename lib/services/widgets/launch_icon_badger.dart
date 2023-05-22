import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import '../../screens/authenticate/profile_stream.dart';
import '../database.dart';

class LaunchIconBadger extends StatefulWidget {
  const LaunchIconBadger({Key? key}) : super(key: key);

  @override
  _LaunchIconBadgerState createState() => _LaunchIconBadgerState();
}

class _LaunchIconBadgerState extends State<LaunchIconBadger> {
  String appBadgeSupported = 'Not supported';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      final bool isBadgeSupported = await FlutterAppBadger.isAppBadgeSupported();
      appBadgeSupported = isBadgeSupported ? 'Supported' : 'Not supported';
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileStream(uid: userService.currentUserID);
  }
}
