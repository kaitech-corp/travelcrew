import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';



class EditLodging extends StatefulWidget {

  var userService = locator<UserService>();
  final LodgingData lodging;
  final Trip trip;
  EditLodging({this.lodging, this.trip});

  @override
  _EditLodgingState createState() => _EditLodgingState();

}
class _EditLodgingState extends State<EditLodging> {

  final _formKey = GlobalKey<FormState>();

  File _image;
  final ImagePicker _picker = ImagePicker();

  Future getImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loading = false;


    String displayName = widget.lodging.displayName;
    String link = widget.lodging.link;
    String lodgingType = widget.lodging.lodgingType;
    String comment = widget.lodging.comment;


    return loading ? Loading() : Scaffold(
        appBar: AppBar(
          title: Text('Add Lodging'),
        ),
        body: SingleChildScrollView(
          child: Builder(
            builder: (context) => Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    ),
                    TextFormField(
                      onSaved: (val){
                        setState(() => lodgingType = val);
                      },
                      enableInteractiveSelection: true,
                      initialValue: lodgingType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Hotel, Airbnb, etc",
                      ),
                      // ignore: missing_return
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a lodging type.';
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    ),
                    TextFormField(
                      onSaved: (val){
                        setState(() => link = val);
                      },
                      enableInteractiveSelection: true,
                      maxLines: 2,
                      initialValue: link,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Link",
                      ),
                      // ignore: missing_return
                      validator: (value) {
                        if ( value.isNotEmpty && !value.startsWith('https')){
                          return 'Please enter a valide link with including https.';
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    ),
                    TextFormField(
                      onSaved: (val){
                        setState(() => comment = val);
                      },
                      enableInteractiveSelection: true,
                      obscureText: false,
                      initialValue: comment,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    ),
                    widget.lodging.urlToImage == null ? Container(
                      child: _image == null
                          ? Text('No image selected.')
                          : Image.file(_image),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 300,
                      ),
                    ):
                    Container(
                      child: _image == null
                          ? Image.network(widget.lodging.urlToImage)
                          : Image.file(_image),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 300,
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        getImage();
                      },
//                              tooltip: 'Pick Image',
                      child: Icon(Icons.add_a_photo),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 30.0),
                      child: RaisedButton(
                        onPressed: () async{
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            form.save();
                            String documentID = widget.trip.documentId;
                            String fieldID = widget.lodging.fieldID;

                            setState(() => loading =true);
                            String message = 'A lodging option has been modified within ${widget.trip.location}';

                            DatabaseService().editLodgingData(comment, displayName, documentID, link, lodgingType, _image, fieldID);
                            widget.trip.accessUsers.forEach((f)  =>  CloudFunction().addNewNotification(
                              message: message,
                              documentID: documentID,
                              type: 'Lodging',
                              ownerID: f,
                            ));
                            setState(() {
                              loading = false;
                            });
                            Navigator.pop(context);
                          }
                        },
                        color: Colors.lightBlue,
                        child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 20)
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        )
    );
  }


}