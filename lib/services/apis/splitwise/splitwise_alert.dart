import 'package:flutter/material.dart';
import 'package:travelcrew/services/apis/splitwise.dart';

import '../../database.dart';

class SplitwiseAlertDialog extends StatefulWidget{
  @override
  _SplitwiseAlertDialogState createState() => _SplitwiseAlertDialogState();
}

class _SplitwiseAlertDialogState extends State<SplitwiseAlertDialog> {

  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          title: const Text(
            'Paste verifier token.',),
          // content: Text('You will no longer have access to this Trip'),
          actions: <Widget>[
            TextFormField(
              controller: myController,

            ),
            TextButton(
              child: const Text('Close',),
              onPressed: () {
                splitWiseAPI(verifier: myController.text);
                navigationService.pop();
              },
            ),
          ],
        );
  }
}