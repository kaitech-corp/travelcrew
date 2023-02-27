import 'package:flutter/material.dart';

import '../../../models/transportation_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';

/// Edit transportation data
class EditTransportation extends StatefulWidget {
  const EditTransportation({Key? key, required this.transportationData}) : super(key: key);
  final TransportationData transportationData;

  @override
  State<EditTransportation> createState() => _EditTransportationState();
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
