import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/explore/edit_trip.dart';

class ExploreLayout extends StatelessWidget{

  final Trip tripdetails;

  ExploreLayout({this.tripdetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ImageLayout("assests/images/barcelona.jpg"),
              ListTile(
                title: Text('${tripdetails.location}'.toUpperCase(), style: TextStyle(fontSize: 20.0)),
                trailing: PopupMenuButton<String>(
                  onSelected: (value){
                    switch (value){
                      case "Edit": {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditTripData(tripdetails: tripdetails,)),
                      );
                    }
                    break;
                    case "Members": {
                      print('Number of members: ${tripdetails.accessUsers.length}');
                    }
                    break;
                      default: {
                        print(value);
                      }
                      break;
                    }
                  },
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) =>[
                    const PopupMenuItem(
                      value: 'Edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Members',
                      child: ListTile(
                        leading: Icon(Icons.people),
                        title: Text('Crew'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Add',
                      child: ListTile(
                        leading: Icon(Icons.person_add),
                        title: Text('Add Member'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Delete',
                      child: ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text('Delete Trip'),
                      ),
                    ),
                  ],
                ),
                subtitle: Text('Owner', style: TextStyle(fontSize: 12.0),),
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Trip: ${tripdetails.travelType}'.toUpperCase()),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Start: ${tripdetails.startDate}'),
                          Text('End: ${tripdetails.endDate}')
                        ],
                      )


                    ],
                  )
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                ),
                child: Text(tripdetails.comment != null ? tripdetails.comment : "No description provided", textScaleFactor: 1.25,),
              ),
//              TextField(
//                cursorColor: Colors.grey,
//                decoration: InputDecoration(
//                    border: OutlineInputBorder(),
//                    hintText: 'A short desription of the trip will be shown here. This box will also be editable.'),
//                maxLines: 4,
//              ),
            ],
          ),
        ),
      )
    );
  }
}

enum Menu{
  Edit,
  Members,
  Add,
  Leave
}

