import 'package:flutter/material.dart';

import '../models/custom_objects.dart';
import '../screens/alerts/alert_dialogs.dart';
import '../services/constants/constants.dart';
import '../services/database.dart';
import '../services/functions/cloud_functions.dart';
import '../services/widgets/loading.dart';

/// Admin page
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return adminDashboard();
  }
}

Widget adminDashboard() {
  return DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: <Tab>[
            Tab(text: 'User Data'),
            Tab(text: 'User Activity'),
            Tab(text: 'Trip Data'),
            Tab(text: 'Feedback'),
            Tab(text: 'Custom Notifications'),
          ],
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
      children: <Widget>[
        Text(
          customNotification,
          style: Theme.of(context).textTheme.headline5,
          textAlign: TextAlign.center,
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
                TravelCrewAlertDialogs().pushCustomNotification(context);
                CloudFunction().addCustomNotification(_message!);
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
      child: StreamBuilder<List<TCFeedback>>(
        builder: (BuildContext context,
            AsyncSnapshot<List<TCFeedback>> feedbackData) {
          if (feedbackData.hasData) {
            final List<TCFeedback> feedbackList = feedbackData.data!;
            return ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (BuildContext context, int index) {
                final TCFeedback item = feedbackList[index];
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
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    subtitle: Text(
                      '$submitted: ${item.timestamp.toDate()}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                );
              },
            );
          } else {
            return const Loading();
          }
        },
        stream: DatabaseService().feedback,
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
