import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import '../../../blocs/lodging_bloc/lodging_bloc.dart';
import '../../../blocs/lodging_bloc/lodging_event.dart';
import '../../../blocs/lodging_bloc/lodging_state.dart';
import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
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
  LodgingBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<LodgingBloc>(context);
    bloc.add(LoadingLodgingData());
    super.initState();
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
