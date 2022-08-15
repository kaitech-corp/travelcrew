// import 'package:flutter/material.dart';
//
// import '../../../models/settings_model.dart';
// import '../../../services/database.dart';
//
// class CustomNotificationWidget extends StatefulWidget{
//   final UserNotificationSettingsData settings;
//
//   const CustomNotificationWidget({Key? key, required this.settings}) : super(key: key);
//
//   @override
//   _CustomNotificationWidgetState createState() => _CustomNotificationWidgetState();
// }
//
// class _CustomNotificationWidgetState extends State<CustomNotificationWidget> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text('Customize Notifications:',style: Theme.of(context).textTheme.subtitle1,),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Direct Messages:',style: Theme.of(context).textTheme.subtitle1,),
//             Switch(value: widget.settings.isDirectMessagingOn, onChanged:widget.settings.isPushNotificationsOn ? (value) {
//                 DatabaseService().changeDMSettings(value);
//             }:
//             null),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Trip Notifications:',style: Theme.of(context).textTheme.subtitle1,),
//             Switch(value: widget.settings.isTripChangeOn, onChanged:widget.settings.isPushNotificationsOn ?  (value){
//                 DatabaseService().changeTripNotificationSettings(value);
//             }:
//             null),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Trip Chats:',style: Theme.of(context).textTheme.subtitle1,),
//             Switch(value: widget.settings.isTripChatOn, onChanged:widget.settings.isPushNotificationsOn ?  (value) {
//                 DatabaseService().changeTripChatNotificationSettings(value);
//             }:
//             null),
//           ],
//         ),
//       ],
//     );
//   }
// }