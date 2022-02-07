import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
import '../../../repositories_v2/lodging_repository.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/loading.dart';
import 'lodging_card.dart';


class LodgingPage extends StatefulWidget {

  final Trip trip;
  LodgingPage({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _LodgingPageState();
  }
}

class _LodgingPageState extends State<LodgingPage> {
  GenericBloc<LodgingData,LodgingRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<LodgingData,LodgingRepository>>(context);
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
        body: BlocBuilder<GenericBloc<LodgingData,LodgingRepository>, GenericState>(
            builder: (context, state){
              if(state is LoadingState){
                return Loading();
              } else if (state is HasDataState<LodgingData>){
                List<LodgingData> lodgingList = state.data;
                return Container(
                  child: ListView.builder(
                      itemCount: lodgingList != null ? lodgingList.length : 0,
                      itemBuilder: (context, index){
                        return LodgingCard(lodging: lodgingList[index],trip: widget.trip,);
                      }),
                );
              } else {
                return nil;
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
