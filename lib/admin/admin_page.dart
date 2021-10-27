import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/widgets/appbar_gradient.dart';
import 'package:travelcrew/size_config/size_config.dart';

import '../services/widgets/loading.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            admin,
            style: Theme.of(context).textTheme.headline5,
          ),
          flexibleSpace: AppBarGradient(),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            height: SizeConfig.screenHeight,
            child: Column(
              children: [
                Text(
                  feedback,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: StreamBuilder(
                      builder: (BuildContext context, feedbackData) {
                        if (feedbackData.hasData) {
                          final List<TCFeedback> feedbackList = feedbackData.data;
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
                                  CloudFunction().removeFeedback(item.fieldID);
                                },
                                child: ListTile(
                                  key: Key(item.fieldID),
                                  title: Text(
                                    item.message,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  subtitle: Text(
                                    '$submitted: ${item.timestamp.toDate()}',
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Loading();
                        }
                      },
                      stream: DatabaseService().feedback,
                    ),
                  ),
                ),
                Text(
                  customNotification,
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                Flexible(flex: 2, child: _buildTextField()),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_message.isNotEmpty) {
                        TravelCrewAlertDialogs()
                            .pushCustomNotification(context);
                        CloudFunction().addCustomNotification(_message);
                      }
                    },
                    child: const Text(push, style: TextStyle(fontSize: 20)),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: textBoxHeight,
      child: TextField(
        autocorrect: true,
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
    );
  }
}
