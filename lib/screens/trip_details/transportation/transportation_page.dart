import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_bloc.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_event.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_state.dart';
import 'package:travelcrew/models/transportation_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/transportation/transportation_card.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/loading.dart';

import '../../../services/database.dart';


class TransportationPage extends StatefulWidget {

  final Trip trip;
  TransportationPage({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _TransportationPageState();
  }
}

class _TransportationPageState extends State<TransportationPage> {
  TransportationBloc bloc;
  @override
  void initState() {
    bloc = BlocProvider.of<TransportationBloc>(context);
    bloc.add(LoadingTransportationData());
    super.initState();
  }

  @override
  void dispose() {
    // bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<TransportationBloc, TransportationState>(
            builder: (context, state){
              if(state is TransportationLoadingState){
                return Loading();
              } else if (state is TransportationHasDataState){
                List<TransportationData> modeList = state.data;
                return Container(
                  child: ListView.builder(
                      itemCount: modeList != null ? modeList.length : 0,
                      itemBuilder: (context, index){
                        return TransportationCard(transportationData: modeList[index],trip: widget.trip,);
                      }
                      ),
                );
              } else {
                return Container();
              }
            }),
        floatingActionButton: FloatingActionButton(

          onPressed: () {
            navigationService.navigateTo(AddNewTransportationRoute,arguments: widget.trip);
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

