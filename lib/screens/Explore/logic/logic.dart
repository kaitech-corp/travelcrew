  import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../Alerts/alert_dialogs.dart';

void shareTrip(BuildContext context, bool isPublic, String tripDocId) {
    if (isPublic) {
      Share.share(
          'View my trip details! https://www.travelcrew.app/tripdetails/$tripDocId');
    } else {
      TravelCrewAlertDialogs().shareTripDialog(context);
    }
  }