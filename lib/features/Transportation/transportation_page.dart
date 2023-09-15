import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../repositories/transportation_repository.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import '../../models/transportation_model/transportation_model.dart';
import '../../models/trip_model/trip_model.dart';
import 'transportation_card.dart';

/// Transportation page
class TransportationPage extends StatefulWidget {
  const TransportationPage({super.key, required this.trip});
  final Trip trip;

  @override
  State<StatefulWidget> createState() {
    return _TransportationPageState();
  }
}

class _TransportationPageState extends State<TransportationPage> {
  late GenericBloc<TransportationModel, TransportationRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<
        GenericBloc<TransportationModel, TransportationRepository>>(context);
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
        body: BlocBuilder<
            GenericBloc<TransportationModel, TransportationRepository>,
            GenericState>(builder: (BuildContext context, GenericState state) {
          if (state is LoadingState) {
            return const Loading();
          } else if (state is HasDataState) {
            final List<TransportationModel> modeList =
                state.data as List<TransportationModel>;
            return Column(
              children: <Widget>[
                const SizedBox(height: 8),
                Expanded(
                  
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: modeList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: SizeConfig.screenWidth / 10.0,
                                // backgroundColor: Colors.yellow,
                                child: TransportationIcon(modeList[index].mode),
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  modeList[index].displayName.length > 10
                                      ? '${modeList[index].displayName.substring(0, 7)}...'
                                      : modeList[index].displayName,
                                  style: titleMedium(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ],
                        );
                      }),
                ),
            
                Expanded(
                  flex: 4,
                  child: ListView.builder(
                      itemCount: modeList != null ? modeList.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        return TransportationCard(
                          transportationData: modeList[index],
                          trip: widget.trip,
                        );
                      }),
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
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
