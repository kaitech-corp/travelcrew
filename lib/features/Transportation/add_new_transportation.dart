import 'package:flutter/material.dart';


import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../models/trip_model/trip_model.dart';


/// Add new mode of Transportation
class AddNewModeOfTransport extends StatefulWidget {
  const AddNewModeOfTransport({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  State<AddNewModeOfTransport> createState() => _AddNewModeOfTransportState();
}
class _AddNewModeOfTransportState extends State<AddNewModeOfTransport> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(title: Text('Transit',style: headlineMedium(context),),),
          body: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Builder(
                  builder: (BuildContext context) => Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            DropdownButton<String>(
                              value: dropdownValue,
                              isExpanded: true,
                              elevation: 16,
                              underline: Container(
                                height: 2,
                                color: Colors.blueAccent,
                              ),
                              onChanged: (String? newValue) {
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
                                <void>{
                                  setState((){
                                    canCarpool = val;
                                  }),
                                }
                            ),
                            if(dropdownValue == 'Carpool') TextFormField(
                                decoration:
                                const InputDecoration(labelText: 'Carpool with who?'),
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.name,
                                onChanged: (String val) =>
                                <void>{
                                  carpoolingWith = val,
                                }
                            ),
                            if(dropdownValue == 'Flying') TextFormField(
                                decoration:
                                const InputDecoration(labelText: 'Airline'),
                                textCapitalization: TextCapitalization.characters,
                                onChanged: (String val) =>
                                <void>{
                                  airline = val,
                                }
                            ),
                            if(dropdownValue == 'Flying') TextFormField(
                                decoration:
                                const InputDecoration(labelText: 'Flight Number'),
                                textCapitalization: TextCapitalization.characters,
                                onChanged: (String val) =>
                                <void>{
                                  flightNumber = val,
                                }
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: Text('Comment',style: titleSmall(context)),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                                  ),
                                  hintText: 'Add a comment.'),
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 10,
                              onChanged: (String val){
                                comment = val;
                              },
                            ),
                          ]),
                  )
              )
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final FormState form = _formKey.currentState!;
            final String documentID = widget.trip.documentId;
            final String message = 'A new travel method has been added to ${widget.trip.tripName}';
            if (form.validate()) {
              try {
                const String action = 'Saving new transportation data';
                CloudFunction().logEvent(action);
                CloudFunction().addTransportation(
                  mode: dropdownValue,
                  tripDocID: widget.trip.documentId,
                  canCarpool: canCarpool,
                  carpoolingWith: carpoolingWith,
                  airline: airline.trim(),
                  comment: comment.trim(),
                  flightNumber: flightNumber.trim(),);
              } on Exception catch (e) {
                CloudFunction().logError('Error adding new Transportation item:  $e');
              }


              try {
                final String action = 'Sending notifications to access users for $documentId';
                CloudFunction().logEvent(action);
                for (final String f in widget.trip.accessUsers) {
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
                }
              } on Exception catch (e) {
                CloudFunction().logError('Error sending notifications for new Transportation item:  $e');
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
