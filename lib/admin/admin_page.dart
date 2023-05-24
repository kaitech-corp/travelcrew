import 'package:flutter/material.dart';

import '../features/Alerts/alert_dialogs.dart';


import '../models/feedback_model/feedback_model.dart';
import '../services/constants/constants.dart';
import '../services/database.dart';
import '../services/functions/cloud_functions.dart';
import '../services/theme/text_styles.dart';
import '../services/widgets/loading.dart';
import 'logic/logic.dart';

/// Admin page
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return adminDashboard(context);
  }
}

Widget adminDashboard(BuildContext context) {
  return DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        titleTextStyle: headlineSmall(context),
        bottom:  TabBar(
          isScrollable: true,
          tabs: const <Tab>[
            Tab(text: 'User Data'),
            Tab(text: 'User Activity'),
            Tab(text: 'Trip Data'),
            Tab(text: 'Feedback'),
            Tab(text: 'Custom Notifications'),
          ],
          labelStyle: titleMedium(context),
        ),
      ),
      body: const TabBarView(children: <Widget>[
        UserData(),
        UserActivity(),
        TripData(),
        Feedback(),
        CustomNotifications()
      ]),
    ),
  );
}

class CustomNotifications extends StatefulWidget {
  const CustomNotifications({Key? key}) : super(key: key);

  @override
  State<CustomNotifications> createState() => _CustomNotificationsState();
}

class _CustomNotificationsState extends State<CustomNotifications> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String? _message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            customNotification,
            style: titleLarge(context),
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(12),
            height: textBoxHeight,
            child: TextField(
              enableInteractiveSelection: true,
              controller: _controller,
              maxLines: maxLines,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: enterMessage,
                filled: true,
              ),
              onChanged: (String value) {
                setState(() {
                  _message = value;
                });
              },
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (_message?.isNotEmpty ?? false) {
                
                CloudFunction().addCustomNotification(_message!);
                TravelCrewAlertDialogs().pushCustomNotification(context);
              }
            },
            child: const Text(push, style: TextStyle(fontSize: 20)),
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 15)),
      ],
    );
  }
}

class Feedback extends StatelessWidget {
  const Feedback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<FeedbackModel>>(
        builder: (BuildContext context,
            AsyncSnapshot<List<FeedbackModel>> feedbackData) {
          if (feedbackData.hasData) {
            final List<FeedbackModel> feedbackList = feedbackData.data!;
            return ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (BuildContext context, int index) {
                final FeedbackModel item = feedbackList[index];
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        )),
                  ),
                  key: Key(item.fieldID),
                  onDismissed: (DismissDirection direction) {
                    // CloudFunction().removeFeedback(item.fieldID);
                  },
                  child: ListTile(
                    key: Key(item.fieldID),
                    title: Text(
                      item.message,
                      style: titleMedium(context),
                    ),
                    subtitle: Text(
                      '$submitted: ${item.timestamp}',
                      style: titleSmall(context),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Loading();
          }
        },
        stream: feedbackStream,
      ),
    );
  }
}

class TripData extends StatelessWidget {
  const TripData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class UserActivity extends StatelessWidget {
  const UserActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class UserData extends StatelessWidget {
  const UserData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
