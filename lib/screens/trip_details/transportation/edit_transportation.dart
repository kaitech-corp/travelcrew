import 'package:flutter/material.dart';

import '../../../models/transportation_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';



class EditTransportation extends StatefulWidget {
  final TransportationData transportationData;
  EditTransportation({this.transportationData});

  @override
  _EditTransportationState createState() => _EditTransportationState();
}
class _EditTransportationState extends State<EditTransportation> {
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
    return Scaffold(
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
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValue = newValue;
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
                                cursorColor: Colors.grey,
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
                    ),
                )
            )
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final form = _formKey.currentState;
          if (form.validate()) {
            CloudFunction().addTransportation(
              mode: dropdownValue,
              tripDocID: widget.transportationData.tripDocID,
              canCarpool: canCarpool,
              carpoolingWith: carpoolingWith,
              airline: airline,
              comment: comment,
              flightNumber: flightNumber,);
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


