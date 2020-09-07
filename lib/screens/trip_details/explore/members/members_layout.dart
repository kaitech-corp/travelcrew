import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';

import '../../../loading.dart';

class MembersLayout extends StatelessWidget{

  final List<Members> members;
  final Trip tripdetails;

  final ScrollController controller = ScrollController();
  bool _isSearching = false;

  MembersLayout({Key key, this.members, this.tripdetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: Icon(Icons.close),
      onPressed: (){
        Navigator.pop(context);
      },
    ),
  ),
  body: retrieveMembers(),
);
  }

  Widget retrieveMembers() {
    return FutureBuilder(
      builder: (context, members) {
        if (members.hasData) {
          return ListView.builder(
            itemCount: members.data.length,
            itemBuilder: (context, index) {
              Members member = members.data[index];
              return userCard(context, member);
            },
          );
        } else {
          return Loading();
        }
      },
      future: DatabaseService().retrieveMembers(tripdetails.documentId, tripdetails.ispublic),
    );
  }

  Widget userCard(BuildContext context, Members member){
    return Card(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ListTile(
              onTap: (){

              },
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.blue,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: member.urlToImage != null ? Image.network(member.urlToImage,height: 75, width: 75,fit: BoxFit.fill,): null,
                ),
              ),
              title: Text('${member.firstname} ${member.lastname}'),
              subtitle: Text("${member.displayName}",
                textAlign: TextAlign.start,),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: (){

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}