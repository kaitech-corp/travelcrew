import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/split_bloc/split_bloc.dart';
import 'package:travelcrew/blocs/split_bloc/split_event.dart';
import 'package:travelcrew/blocs/split_bloc/split_state.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/split_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/cost/split_package.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/navigation/router.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

class SplitBlocBuilder extends StatefulWidget {
  final Trip trip;
  const SplitBlocBuilder({
    Key key, this.trip,
  }) : super(key: key);

  @override
  _SplitBlocBuilderState createState() => _SplitBlocBuilderState();
}

class _SplitBlocBuilderState extends State<SplitBlocBuilder> {
  SplitBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<SplitBloc>(context);
    bloc.add(LoadingSplitData());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplitBloc, SplitState>(
        builder: (context, state){
          if(state is SplitLoadingState){
            return Loading();
          } else if (state is SplitHasDataState){
            List<SplitObject> items = state.data;
            if (items != null) {
              return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    SplitObject item = items[index];
                    return Card(
                      margin: EdgeInsets.all(4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0))
                      ),
                      elevation: 15,
                      shadowColor: Colors.grey,
                      child: InkWell(
                        onLongPress: (){
                          if (userService.currentUserID == item.purchasedByUID) {
                            SplitPackage().editSplitDialog(context, item);
                          }
                        },
                        onTap: (){
                          navigationService.navigateTo(SplitDetailsPageRoute,arguments: SplitDetailsArguments(splitObject: item,purchasedByUID: item.purchasedByUID,trip: widget.trip));

                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.itemName,
                                style: SizeConfig.tablet ? Theme.of(context).textTheme.headline4 : Theme.of(context).textTheme.headline6,),
                              Text('Total: \$${item.itemTotal.toStringAsFixed(2)}',style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cantata One',color: Colors.green)),
                              Text('Remaining: \$${item?.amountRemaining?.toStringAsFixed(2) ?? item.itemTotal.toStringAsFixed(2)}  (${item.userSelectedList.length}pp)',style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cantata One',color: Colors.red)),
                              // Text('Description: ${item.itemType}',style: Theme.of(context).textTheme.subtitle2),
                              FutureBuilder(
                                builder: (context, snapshot){
                                  if(snapshot.hasData){
                                    UserPublicProfile user = snapshot.data;
                                    return Text('Purchased by: ${user.displayName}',style: Theme.of(context).textTheme.subtitle2);
                                  } else {
                                    return Container();
                                  }
                                },
                                future: DatabaseService().getUserProfile(item.purchasedByUID),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            } else {
              return ListTile(
                title: const Text('No items have been split.'),
              );
            }
          } else {
            return ListTile(
              title: const Text('No items have been split.'),
            );
          }
        });
  }
}