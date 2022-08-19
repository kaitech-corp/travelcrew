import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/transportation_model.dart';
import '../../../models/trip_model.dart';
import '../../../repositories/transportation_repository.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import 'transportation_card.dart';

/// Transportation page
class TransportationPage extends StatefulWidget {
  final Trip trip;
  TransportationPage({required this.trip});

  @override
  State<StatefulWidget> createState() {
    return _TransportationPageState();
  }
}

class _TransportationPageState extends State<TransportationPage> {

  late GenericBloc<TransportationData,TransportationRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<TransportationData,TransportationRepository>>(context);
    bloc.add(LoadingGenericData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<GenericBloc<TransportationData,TransportationRepository>, GenericState>(
            builder: (context, state) {
          if (state is LoadingState) {
            return Loading();
          } else if (state is HasDataState) {
            List<TransportationData> modeList = state.data as List<TransportationData>;
            return Column(
              children: [
                Container(
                  height: 16,
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: modeList.length,
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
                              Text(modeList[index].displayName!)
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
