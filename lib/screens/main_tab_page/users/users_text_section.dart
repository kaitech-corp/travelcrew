import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';

class UsersTextSection extends StatelessWidget{
  final UserProfile allUsers;

  UsersTextSection({this.allUsers});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => Explore()),
//          );
          print('Card tapped.');
        },
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    color: Colors.blue,
                  ),
                  child: Image.network(allUsers.urlToImage,height: 75, width: 75,fit: BoxFit.fill,),
                ),
                title: Text('${allUsers.firstname} ${allUsers.lastname}'),
                subtitle: Text("${allUsers.displayName}",
                  textAlign: TextAlign.start,),
//              isThreeLine: true,
              ),
              FlatButton(
                child: Text('Follow'),
                shape: Border.all(width: 1, color: Colors.blue),
                onPressed: () {


                  /* ... */ },
              ),
            ],
          ),
        ),
      ),
    );
  }
}