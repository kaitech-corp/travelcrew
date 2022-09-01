import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/appbar_gradient.dart';
import '../../alerts/alert_dialogs.dart';

class FeedbackPage extends StatefulWidget{
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late TextEditingController _controller;

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

  late String _message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(Intl.message('Feedback'),style: Theme.of(context).textTheme.headline5,),
            flexibleSpace: const AppBarGradient(),
          ),
          body: Container(
            padding: const EdgeInsets.all(8.0),
            height: MediaQuery.of(context).size.height *.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.all(5.0),),
                Center(child: Text(Intl.message('Feel free to share your thoughts with us.'),style: Theme.of(context).textTheme.subtitle1,)),
                _buildTextField(),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CloudFunction().giveFeedback(_message);
                      navigationService.pop();
                      TravelCrewAlertDialogs().submitFeedbackAlert(context);
                    },
                    child: Text(Intl.message('Send'), style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 30),
                Center(child: SelectableText(collaboratingText(),style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,)),
              ],
            ),
          )
      ),
    );
  }

  Widget _buildTextField() {
    const int maxLines = 5;

    return Container(
      margin: const EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        enableInteractiveSelection: true,
        controller: _controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: Intl.message("What's on your mind?"),
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
