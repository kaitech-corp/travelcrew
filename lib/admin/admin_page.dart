import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';

import '../loading.dart';



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
          title: Text('Admin',style: Theme.of(context).textTheme.headline3,),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(10),
            height: SizeConfig.screenHeight,
            child: Column(
              children: [
                Text('Feedback',style: Theme.of(context).textTheme.headline4,),
                Flexible(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: FutureBuilder(
                      builder: (context, feedbackList) {
                        if(feedbackList.hasData) {
                          return ListView.builder(
                            itemCount: feedbackList.data.length,
                            itemBuilder: (context, index) {
                              TCFeedback feedback = feedbackList.data[index];
                              var item = feedback;
                              return Dismissible(
                                background: Container(color: Colors.red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Icon(Icons.delete, color: Colors.white,),
                                      Icon(Icons.delete, color: Colors.white,)
                                    ],
                                  ),),
                                key: Key(item.fieldID),
                                onDismissed: (direction) {
                                  setState(() {
                                    feedbackList.data.removeAt(index);
                                  });
                                  CloudFunction().removeFeedback(item.fieldID);
                                },
                                child: ListTile(
                                  title: Text('${feedback.message}',),
                                  subtitle: Text('Submitted: ${feedback.timestamp.toDate()}'),
                                ),
                              );
                            },
                          );
                        } else {
                          return Loading();
                        }
                      },
                      future: DatabaseService().feedback(),

                    ),
                  ),
                ),
                Text('Custom Notification',style: Theme.of(context).textTheme.headline4, textAlign: TextAlign.center,),
                Flexible(flex: 2, child: _buildTextField()),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      if (_message.isNotEmpty) {
                        CloudFunction().addCustomNotification(_message);
                      }
                    },
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: <Color>[
                            Color(0xFF0D47A1),
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20 , 10 ),
                      child:
                      const Text('Push', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField() {
    final maxLines = 5;

    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        autocorrect: true,
        enableInteractiveSelection: true,
        controller: _controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: "Enter a message",
          fillColor: Colors.grey[300],
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