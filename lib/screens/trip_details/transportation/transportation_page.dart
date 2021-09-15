import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_bloc.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_event.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_state.dart';
import 'package:travelcrew/models/transportation_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/transportation/transportation_card.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<TransportationBloc, TransportationState>(
            builder: (context, state) {
          if (state is TransportationLoadingState) {
            return Loading();
          } else if (state is TransportationHasDataState) {
            List<TransportationData> modeList = state.data;
            return Column(
              children: [
                Container(
                  height: 16,
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: modeList != null ? modeList.length : 0,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: SizeConfig.screenWidth / 10.0,
                                // backgroundColor: Colors.yellow,
                                child: TransportationIcon(modeList[index].mode),
                              ),
                              Text(modeList[index].displayName)
                            ],
                          ),
                        );
                      }),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: ListView.builder(
                        itemCount: modeList != null ? modeList.length : 0,
                        itemBuilder: (context, index) {
                          return TransportationCard(
                            transportationData: modeList[index],
                            trip: widget.trip,
                          );
                        }),
                  ),
                ),
              ],
            );
          } else {
            return nil;
          }
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigationService.navigateTo(AddNewTransportationRoute,
                arguments: widget.trip);
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
