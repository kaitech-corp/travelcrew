import 'package:flutter/material.dart';
import 'package:travelcrew/admin/admin_bloc.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../services/widgets/loading.dart';



class AdminPage extends StatefulWidget{
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _message;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(admin,style: Theme.of(context).textTheme.headline5,),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            height: SizeConfig.screenHeight,
            child: Column(
              children: [
                Text(feedback,style: Theme.of(context).textTheme.headline5,),
                Flexible(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: StreamBuilder(
                      builder: (context, feedbackData) {
                        if(feedbackData.hasData) {
                          return ListView.builder(
                            itemCount: feedbackData.data.length,
                            itemBuilder: (context, index) {
                              List<TCFeedback> feedbackList = feedbackData.data;
                              var item = feedbackList[index];
                              return Dismissible(
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red,
                                  child: const Align(alignment: Alignment.centerRight,child: Icon(Icons.delete, color: Colors.white,)),),
                                key: Key(item.fieldID),
                                onDismissed: (direction) {
                                  CloudFunction().removeFeedback(item.fieldID);
                                },
                                child: ListTile(
                                  key: Key(item.fieldID),
                                  title: Text('${item.message}',style: Theme.of(context).textTheme.subtitle1,),
                                  subtitle: Text('$submitted: ${item.timestamp.toDate()}',style: Theme.of(context).textTheme.subtitle2,),
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
                Text(customNotification,style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center,),
                Flexible(flex: 2, child: _buildTextField()),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_message.isNotEmpty) {
                        TravelCrewAlertDialogs().pushCustomNotification(context);
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
      margin: EdgeInsets.all(12),
      height: textBoxHeight,
      child: TextField(
        autocorrect: true,
        enableInteractiveSelection: true,
        controller: _controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
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