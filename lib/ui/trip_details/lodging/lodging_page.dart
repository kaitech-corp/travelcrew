import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/blocs/lodging_bloc/lodging_bloc.dart';
import 'package:travelcrew/blocs/lodging_bloc/logding_state.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/lodging_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging_list.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/ui/trip_details/lodging/lodging_card.dart';


class Lodging extends StatefulWidget {

  final Trip trip;
  Lodging({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _LodgingState();
  }
}

class _LodgingState extends State<Lodging> {
  LodgingBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<LodgingBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<LodgingBloc, LodgingState>(
            builder: (context, state){
              if(state is LodgingLoadingState){
                return Loading();
              } else if (state is LodgingHasDataState){
                List<LodgingData> lodgingList = state.data;
                return Container(
                  child: ListView.builder(
                      itemCount: lodgingList != null ? lodgingList.length : 0,
                      itemBuilder: (context, index){
                        return LodgingCard(lodging: lodgingList[index],trip: widget.trip,);
                      }),
                );
              } else {
                return Container();
              }
            }),
        floatingActionButton: FloatingActionButton(

          onPressed: () {
            navigationService.navigateTo(AddNewLodgingRoute, arguments: widget.trip);
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
