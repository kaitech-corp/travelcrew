import 'package:flutter/material.dart';
import 'package:travelcrew/models/trip_model.dart';

import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';


/// Add new mode of Transportation
class AddNewModeOfTransport extends StatefulWidget {
  final Trip trip;
  AddNewModeOfTransport({required this.trip});

  @override
  _AddNewModeOfTransportState createState() => _AddNewModeOfTransportState();
}
class _AddNewModeOfTransportState extends State<AddNewModeOfTransport> {
  final _formKey = GlobalKey<FormState>();

  String comment = '';
  String displayName = '';
  String documentId = '';
  bool canCarpool = false;
  String carpoolingWith = '';
  String airline = '';
  String flightNumber = '';
  String dropdownValue = 'Driving';



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(title: Text('Transit',style: Theme.of(context).textTheme.headline5,),),
          body: Container(
              child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Builder(
                      builder: (context) => Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButton<String>(
                                  value: dropdownValue,
                                  isExpanded: true,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.blueAccent,
                                  ),
                                  onChanged: (newValue) {
                                    setState(() {
                                      dropdownValue = newValue ?? '';
                                    });
                                  },
                                  items: modes
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                                if(dropdownValue == 'Driving') SwitchListTile(
                                    title: const Text('Open to Carpooling?'),
                                    value: canCarpool,
                                    onChanged: (bool val) =>
                                    {
                                      setState((){
                                        canCarpool = val;
                                      }),
                                    }
                                ),
                                if(dropdownValue == 'Carpool') TextFormField(
                                    decoration:
                                    InputDecoration(labelText: 'Carpool with who?'),
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.name,
                                    onChanged: (val) =>
                                    {
                                      carpoolingWith = val,
                                    }
                                ),
                                if(dropdownValue == 'Flying') TextFormField(
                                    decoration:
                                    InputDecoration(labelText: 'Airline'),
                                    textCapitalization: TextCapitalization.characters,
                                    onChanged: (val) =>
                                    {
                                      airline = val,
                                    }
                                ),
                                if(dropdownValue == 'Flying') TextFormField(
                                    decoration:
                                    InputDecoration(labelText: 'Flight Number'),
                                    textCapitalization: TextCapitalization.characters,
                                    onChanged: (val) =>
                                    {
                                      flightNumber = val,
                                    }
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                  child: Text('Comment',style: Theme.of(context).textTheme.subtitle2),
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                                      ),
                                      hintText: 'Add a comment.'),
                                  textCapitalization: TextCapitalization.sentences,
                                  maxLines: 10,
                                  onChanged: (val){
                                    comment = val;
                                  },
                                ),
                              ]),
                      )
                  )
              ),
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final form = _formKey.currentState!;
            String documentID = widget.trip.documentId!;
            String message = 'A new travel method has been added to ${widget.trip.tripName}';
            if (form.validate()) {
              try {
                String action = 'Saving new transportation data';
                CloudFunction().logEvent(action);
                CloudFunction().addTransportation(
                  mode: dropdownValue,
                  tripDocID: widget.trip.documentId!,
                  canCarpool: canCarpool,
                  carpoolingWith: carpoolingWith,
                  airline: airline.trim(),
                  comment: comment.trim(),
                  flightNumber: flightNumber.trim(),);
              } on Exception catch (e) {
                CloudFunction().logError('Error adding new Transportation item:  ${e.toString()}');
              }


              try {
                String action = 'Sending notifications to access users for $documentId';
                CloudFunction().logEvent(action);
                widget.trip.accessUsers!.forEach((f) {
                  if(f != userService.currentUserID){
                    CloudFunction().addNewNotification(
                      message: message,
                      documentID: documentID,
                      type: 'Travel',
                      uidToUse: f,
                      ownerID: userService.currentUserID,
                      ispublic: widget.trip.ispublic,
                    );
                  }
                });
              } on Exception catch (e) {
                CloudFunction().logError('Error sending notifications for new Transportation item:  ${e.toString()}');
              }
              navigationService.pop();
            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}


