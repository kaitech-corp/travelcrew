// import 'package:flutter/material.dart';
//
// class SurveyPage extends StatefulWidget{
//
//   @override
//   _SurveyPageState createState() => _SurveyPageState();
// }
//
// class _SurveyPageState extends State<SurveyPage> {
//     final _formKey = GlobalKey<FormState>();
//
//     @override
//     Widget build(BuildContext context) {
//       return Scaffold(
//           appBar: AppBar(title: Text('Survey',style: Theme.of(context).textTheme.headline3,)),
//           body: Container(
//               child: SingleChildScrollView(
//                   padding:
//                   const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
//                   child: Builder(
//                       builder: (context) => Form(
//                           key: _formKey,
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 TextFormField(
//                                     enableInteractiveSelection: true,
//                                     textCapitalization: TextCapitalization.words,
//                                     decoration:
//                                     const InputDecoration(labelText: 'Trip Name'),
//                                     // ignore: missing_return
//                                     validator: (value) {
//                                       if (value.isEmpty) {
//                                         return 'Please enter a trip name';
//                                         // ignore: missing_return
//                                       }
//                                     },
//                                     onChanged: (val) =>
//                                     {
//                                       tripName = val,
//                                     }
//                                 ),
//                                 TextFormField(
//                                     enableInteractiveSelection: true,
//                                     textCapitalization: TextCapitalization.words,
//                                     autocorrect: true,
//                                     decoration:
//                                     const InputDecoration(labelText: 'Type (i.e. work, vacation, wedding)'),
//                                     // ignore: missing_return
//                                     validator: (value) {
//                                       if (value.isEmpty) {
//                                         return 'Please enter a type.';
//                                         // ignore: missing_return
//                                       }
//                                     },
//                                     onChanged: (val) =>
//                                     {
//                                       travelType = val,
//                                     }
//                                 ),
//                                 TextFormField(
//                                   controller: myController,
//                                   enableInteractiveSelection: true,
//                                   textCapitalization: TextCapitalization.words,
//                                   decoration: const InputDecoration(labelText:'Location'),
//                                   // ignore: missing_return
//                                   validator: (value) {
//                                     if (value.isEmpty) {
//                                       return 'Please enter a location.';
//                                       // ignore: missing_return
//                                     }
//                                   },
//                                   onSaved: (value){
//                                     myController.text = value;
//                                   },
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                     children: <Widget>[
//                                       Text(_labelTextDepart,style: Theme.of(context).textTheme.subtitle1,),
// //                                SizedBox(height: 16),
//                                       ButtonTheme(
//                                         minWidth: 150,
//                                         child: RaisedButton(
//                                           shape:  RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(20),
//                                           ),
//                                           child: const Text(
//                                             'Start Date',
//                                           ),
//                                           onPressed: () async {
//                                             _showDatePickerDepart();
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                     children: <Widget>[
//                                       Text(_labelTextReturn,style: Theme.of(context).textTheme.subtitle1,),
// //                                SizedBox(height: 16),
//                                       ButtonTheme(
//                                         minWidth: 150,
//                                         child: RaisedButton(
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(20),
//                                           ),
//                                           child: const Text(
//                                             'End Date',
//                                           ),
//                                           onPressed: () {
//                                             _showDatePickerReturn();
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SwitchListTile(
//                                     title: const Text('Public'),
//                                     value: ispublic,
//                                     onChanged: (bool val) =>
//                                     {
//                                       setState((){
//                                         ispublic = val;
//                                       }),
//
//                                     }
//                                 ),
//
//                                 Container(
//                                   padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
//                                   child: Text('Description',style: Theme.of(context).textTheme.subtitle1,),
//                                 ),
//                                 TextFormField(
//                                   enableInteractiveSelection: true,
//                                   textCapitalization: TextCapitalization.sentences,
//                                   cursorColor: Colors.grey,
//                                   decoration: const InputDecoration(
//                                       border: OutlineInputBorder(),
//                                       hintText: 'Add a short description.'),
//                                   onChanged: (val){
//                                     comment = val;
//                                   },
//                                 ),
//                                 Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16.0, horizontal: 16.0),
//                                     child: RaisedButton(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                         ),
//                                         onPressed: () {
//                                           final form = _formKey.currentState;
//                                           form.save();
//                                           if (form.validate()) {
//
//                                           }
//                                         },
//                                         child: const Text('Add Trip'))),
//                               ]))))));
//     }
//   }
//
// }