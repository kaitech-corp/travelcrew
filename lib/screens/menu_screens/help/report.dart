import 'package:flutter/material.dart';
import 'package:travelcrew/models/activity_model.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/lodging_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';

class ReportContent extends StatefulWidget{

  final String type;
  final UserPublicProfile userAccount;
  final ActivityData activity;
  final LodgingData lodging;
  final Trip tripDetails;

  const ReportContent({Key key, this.type, this.userAccount, this.activity, this.lodging, this.tripDetails}) : super(key: key);
  @override
  _ReportContentState createState() => _ReportContentState();
}

class _ReportContentState extends State<ReportContent> {
  String collection;
  String docID;
  String offenderID;
  String urlToImage;

  void saveData(String type){
    switch (type){
      case "userAccount": {
       setState(() {
         collection = 'users';
         docID = widget.userAccount.uid;
         offenderID = docID;
         urlToImage = widget.userAccount.urlToImage;
       });
      }
      break;
      case "activity": {
        setState(() {
          collection = 'activities';
          docID = widget.activity.fieldID;
          offenderID = widget.activity.uid;
        });
      }
      break;
      case "lodging": {
        setState(() {
          collection = 'lodging';
          docID = widget.lodging.fieldID;
          offenderID = widget.lodging.uid;
        });
      }
      break;
      case "tripDetails": {
        setState(() {
          if(widget.tripDetails.ispublic) {
            collection = 'trips';
          } else {
            collection = 'privateTrips';
          }
          docID = widget.tripDetails.documentId;
          offenderID = widget.tripDetails.ownerID;
          urlToImage = widget.tripDetails.urlToImage;
        });
      }
      break;
      default: {
        setState(() {
          collection = 'unknown';
          docID = '';
          offenderID = docID;
          urlToImage = '';
        });
      }
      break;
    }
  }

  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
    saveData(widget.type);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _message;

  var reportType = {
    'Content' : 'Content (i.e. image, language) is inappropriate.',
    'Identity' : 'This account is pretending to be someone else.',
    'Spam' : 'You believe this to be a spam account.',
    'Other' : 'Please describe below.'
  };
  List reportList = ['Content', 'Identity', 'Spam', 'Other'];
  String itemType = 'Content';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Report User'),
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(top: 5),),
                Text('Report this user for...',style: Theme.of(context).textTheme.subtitle1,),
                const Padding(padding: EdgeInsets.only(top: 5),),
                Container(
                  height: MediaQuery.of(context).size.height * .3,
                  child: ListView.builder(
                    itemCount: reportList.length,
                      itemBuilder: (context, index){
                        return RadioListTile(
                          title: Text(reportList[index],style: Theme.of(context).textTheme.subtitle1,),
                          subtitle: Text(reportType[reportList[index]],style: Theme.of(context).textTheme.subtitle2,),
                          value: reportList[index],
                          groupValue: itemType,
                          onChanged: (value) {
                            setState(() {
                              itemType = value;
                              print(itemType);
                            });
                          }
                        );
                      }),
                ),

                _buildTextField(),
                if(widget.userAccount != null)  Center(child: Text('Reporting: ${widget.userAccount.firstName} ${widget.userAccount.lastName}',style: Theme.of(context).textTheme.subtitle1,)),
                if(widget.activity != null) Center(child: Text('Reporting: ${widget.activity.displayName}',style: Theme.of(context).textTheme.subtitle1,)),
                if(widget.lodging != null) Center(child: Text('Reporting: ${widget.lodging.displayName}',style: Theme.of(context).textTheme.subtitle1,)),
                if(widget.tripDetails != null) Center(child: Text('Reporting: ${widget.tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle1,)),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CloudFunction().reportUser(collection, docID, offenderID, _message, itemType, urlToImage);
                      navigationService.pop();
                      TravelCrewAlertDialogs().submittedAlert(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            const Color(0xFF0D47A1),
                            const Color(0xFF1976D2),
                            const Color(0xFF42A5F5),
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
      ),
    );
  }

  Widget _buildTextField() {
    final maxLines = 5;

    return Container(
      margin: const EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        style: Theme.of(context).textTheme.subtitle1,
        controller: _controller,
        maxLines: maxLines,
        decoration: const InputDecoration(
          hintText: "Please describe the reasoning for this report and/or add additional details.",
          fillColor: Colors.grey,
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

