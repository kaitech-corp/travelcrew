import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
import '../../../repositories/lodging_repository.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/loading.dart';
import 'lodging_card.dart';

/// Lodging page
class LodgingPage extends StatefulWidget {
  const LodgingPage({Key? key, required this.trip}) : super(key: key);

  final Trip trip;

  @override
  State<StatefulWidget> createState() {
    return _LodgingPageState();
  }
}

class _LodgingPageState extends State<LodgingPage> {
  late GenericBloc<LodgingData, LodgingRepository> bloc;

  @override
  void initState() {
    bloc =
        BlocProvider.of<GenericBloc<LodgingData, LodgingRepository>>(context);
    bloc.add(LoadingGenericData());
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
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<GenericBloc<LodgingData, LodgingRepository>,
            GenericState>(builder: (BuildContext context, GenericState state) {
          if (state is LoadingState) {
            return const Loading();
          } else if (state is HasDataState) {
            final List<LodgingData> lodgingList =
                state.data as List<LodgingData>;
            return ListView.builder(
                itemCount: lodgingList.length,
                itemBuilder: (BuildContext context, int index) {
                  return LodgingCard(
                    lodging: lodgingList[index],
                    trip: widget.trip,
                  );
                });
          } else {
            return nil;
          }
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigationService.navigateTo(AddNewLodgingRoute,
                arguments: widget.trip);
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
