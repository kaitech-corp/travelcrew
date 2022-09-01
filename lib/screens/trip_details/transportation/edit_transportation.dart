import 'package:flutter/material.dart';

import '../../../models/transportation_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';

/// Edit transportation data
class EditTransportation extends StatefulWidget {
  const EditTransportation({required this.transportationData});
  final TransportationData transportationData;

  @override
  _EditTransportationState createState() => _EditTransportationState();
}
class _EditTransportationState extends State<EditTransportation> {
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
    return Scaffold(
        appBar: AppBar(title: Text('Transit',style: Theme.of(context).textTheme.headline5,),),
        body: Container(
            child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Builder(
                    builder: (BuildContext context) => Form(
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
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
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
                                  const InputDecoration(labelText: 'Carpool with who?'),
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.name,
                                  onChanged: (String val) =>
                                  {
                                    carpoolingWith = val,
                                  }
                              ),
                              if(dropdownValue == 'Flying') TextFormField(
                                  decoration:
                                  const InputDecoration(labelText: 'Airline'),
                                  textCapitalization: TextCapitalization.characters,
                                  onChanged: (String val) =>
                                  {
                                    airline = val,
                                  }
                              ),
                              if(dropdownValue == 'Flying') TextFormField(
                                  decoration:
                                  const InputDecoration(labelText: 'Flight Number'),
                                  textCapitalization: TextCapitalization.characters,
                                  onChanged: (String val) =>
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
                    ),
                )
            )
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final FormState form = _formKey.currentState!;
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


