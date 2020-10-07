import 'package:flutter/material.dart';
import 'package:travelcrew/services/cloud_functions.dart';

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
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feedback',style: Theme.of(context).textTheme.headline3,),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          height: MediaQuery.of(context).size.height *.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 5),),
              Text('Feel free to share your thoughts with us.',style: Theme.of(context).textTheme.headline2,),
              _buildTextField(),
              Center(child: Text('Interested in collaborating? Email KaiTech2020@gmail.com directly.',style: Theme.of(context).textTheme.subtitle2,textAlign: TextAlign.center,)),
              const SizedBox(height: 30),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    CloudFunction().giveFeedback(_message);
                    _submitAlert(context);
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
                    const Text('Send', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildTextField() {
    final maxLines = 5;

    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        controller: _controller,
        maxLines: maxLines,
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

  _submitAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback Submitted!'),
          content: const Text(
              'We thank you for your feedback.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
