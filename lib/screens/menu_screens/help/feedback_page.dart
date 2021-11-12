import 'package:flutter/material.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/widgets/appbar_gradient.dart';

class FeedbackPage extends StatefulWidget{
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
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
            title: Text('Feedback',style: Theme.of(context).textTheme.headline5,),
            flexibleSpace: AppBarGradient(),
          ),
          body: Container(
            padding: const EdgeInsets.all(8.0),
            height: MediaQuery.of(context).size.height *.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.all(5.0),),
                Center(child: Text('Feel free to share your thoughts with us.',style: Theme.of(context).textTheme.subtitle1,)),
                _buildTextField(),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CloudFunction().giveFeedback(_message);
                      navigationService.pop();
                      TravelCrewAlertDialogs().submitFeedbackAlert(context);
                    },
                    child: const Text('Send', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 30),
                Center(child: SelectableText(collaboratingText,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,)),
              ],
            ),
          )
      ),
    );
  }

  Widget _buildTextField() {
    final maxLines = 5;

    return Container(
      margin: const EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        autocorrect: true,
        enableInteractiveSelection: true,
        controller: _controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: "What's on your mind?",
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
