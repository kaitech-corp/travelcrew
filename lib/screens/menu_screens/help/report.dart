import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/activity_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../alerts/alert_dialogs.dart';

class ReportContent extends StatefulWidget {

  const ReportContent(
      {Key? key,
      required this.type,
      this.userAccount,
      this.activity,
      this.lodging,
      this.trip})
      : super(key: key);
  final String type;
  final UserPublicProfile? userAccount;
  final ActivityData? activity;
  final LodgingData? lodging;
  final Trip? trip;
  @override
  _ReportContentState createState() => _ReportContentState();
}

class _ReportContentState extends State<ReportContent> {
  late String collection;
  late String docID;
  late String offenderID;
  late String urlToImage;

  void saveData(String type) {
    switch (type) {
      case 'userAccount':
        {
          setState(() {
            collection = 'users';
            docID = widget.userAccount!.uid!;
            offenderID = docID;
            urlToImage = widget.userAccount!.urlToImage!;
          });
        }
        break;
      case 'activity':
        {
          setState(() {
            collection = 'activities';
            docID = widget.activity!.fieldID!;
            offenderID = widget.activity!.uid!;
          });
        }
        break;
      case 'lodging':
        {
          setState(() {
            collection = 'lodging';
            docID = widget.lodging!.fieldID!;
            offenderID = widget.lodging!.uid!;
          });
        }
        break;
      case 'trip':
        {
          setState(() {
            if (widget.trip!.ispublic) {
              collection = 'trips';
            } else {
              collection = 'privateTrips';
            }
            docID = widget.trip!.documentId!;
            offenderID = widget.trip!.ownerID!;
            urlToImage = widget.trip!.urlToImage!;
          });
        }
        break;
      default:
        {
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

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    saveData(widget.type);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late String _message;

  Map<String, String> reportType = {
    'Content': Intl.message('Content (i.e. image, language) is inappropriate.'),
    'Identity': Intl.message('This account is pretending to be someone else.'),
    'Spam': Intl.message('You believe this to be a spam account.'),
    'Other': Intl.message('Please describe below.')
  };
  List<String> reportList = ['Content', 'Identity', 'Spam', 'Other'];
  String itemType = 'Content';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
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
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                Text(Intl.message
                  ('Report this user for...'),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  child: ListView.builder(
                      itemCount: reportList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return RadioListTile(
                            title: Text(
                              reportList[index],
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            subtitle: Text(
                              reportType[reportList[index]]!,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            value: reportList[index],
                            groupValue: itemType,
                            onChanged: (Object? value) {
                              setState(() {
                                itemType = value as String;
                              });
                            });
                      }),
                ),
                _buildTextField(),
                if (widget.userAccount != null)
                  Center(
                      child: Text(
                    'Reporting: ${widget.userAccount!.firstName} '
                        '${widget.userAccount!.lastName}',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
                if (widget.activity != null)
                  Center(
                      child: Text(
                    'Reporting: ${widget.activity!.displayName}',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
                if (widget.lodging != null)
                  Center(
                      child: Text(
                    'Reporting: ${widget.lodging!.displayName}',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
                if (widget.trip != null)
                  Center(
                      child: Text(
                    'Reporting: ${widget.trip!.displayName}',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CloudFunction().reportUser(collection, docID, offenderID,
                          _message, itemType, urlToImage);
                      navigationService.pop();
                      TravelCrewAlertDialogs().submittedAlert(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFF0D47A1),
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: const Text('Send', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildTextField() {
    const int maxLines = 5;

    return Container(
      margin: const EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        style: Theme.of(context).textTheme.subtitle1,
        controller: _controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: Intl.message('Please describe the reasoning for this report '
              'and/or add additional details.'),
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
