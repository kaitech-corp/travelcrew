import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/constants/constants.dart';



class EditTransportation extends StatefulWidget {
  final Trip trip;
  EditTransportation({this.trip});

  @override
  _EditTransportationState createState() => _EditTransportationState();
}
class _EditTransportationState extends State<EditTransportation> {
  final _formKey = GlobalKey<FormState>();
  // File _image;
  // final ImagePicker _picker = ImagePicker();
  //
  // DateTime _fromDateDepart = DateTime.now();
  // DateTime _fromDateReturn = DateTime.now();
  //
  // String get _labelTextDepart {
  //   startDate = DateFormat.yMMMd().format(_fromDateDepart);
  //   startDateTimeStamp = Timestamp.fromDate(_fromDateDepart);
  //   return DateFormat.yMMMd().format(_fromDateDepart);
  // }
  // String get _labelTextReturn {
  //   endDate = DateFormat.yMMMd().format(_fromDateReturn);
  //   endDateTimeStamp = Timestamp.fromDate(_fromDateReturn);
  //   return DateFormat.yMMMd().format(_fromDateReturn);
  // }
  //
  // Future<void> _showDatePickerDepart() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: _fromDateDepart,
  //     firstDate: DateTime(2015, 1),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null && picked != _fromDateDepart) {
  //     setState(() {
  //       _fromDateDepart = picked;
  //     });
  //   }
  // }
  // Future<void> _showDatePickerReturn() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: _fromDateReturn,
  //     firstDate: DateTime(2015, 1),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null && picked != _fromDateReturn) {
  //     setState(() {
  //       _fromDateReturn = picked;
  //     });
  //   }
  // }

  String comment = '';
  String displayName = '';
  String documentId = '';
  bool canCarpool = false;
  String carpoolingWith = '';
  String airline = '';
  String flightNumber = '';

  // File urlToImage;
  // String startDate = '';
  // String endDate = '';
  // Timestamp startDateTimeStamp;
  // Timestamp endDateTimeStamp;


  String dropdownValue = 'Driving';
  //
  // Future getImage() async {
  //   var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);
  //
  //   setState(() {
  //     _image = File(image.path);
  //     urlToImage = _image;
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Transit',style: Theme.of(context).textTheme.headline3,),),
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
                                // icon: Icon(Icons.arrow_downward),
                                // iconSize: 24,
                                isExpanded: true,
                                elevation: 16,
                                // style: Theme.of(context).textTheme.headline4,
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
//

                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                  child: RaisedButton(
                                      onPressed: () {
                                        final form = _formKey.currentState;
                                        if (form.validate()) {
                                          CloudFunction().addTransportation(
                                            mode: dropdownValue,
                                            tripDocID: widget.trip.documentId,
                                            canCarpool: canCarpool,
                                            carpoolingWith: carpoolingWith,
                                            airline: airline,
                                            comment: comment,
                                            flightNumber: flightNumber,);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Add'))),
                            ]))))));
  }
}


