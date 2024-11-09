import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../repositories/split_repository.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import '../../models/cost_model/cost_object_model.dart';
import '../../models/split_model/split_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/constants/constants.dart';
import 'components/prepaid_details_card.dart';
import 'logic/split_functions.dart';
import 'split_package.dart';

/// Split Page
class SplitPage extends StatefulWidget {
  const SplitPage({
    super.key,
    required this.trip,
  });
  final Trip trip;

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  late GenericBloc<SplitObject, SplitRepository> bloc;
  String selectedCurrency = 'USD';

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<SplitObject, SplitRepository>>(context);
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
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<GenericBloc<SplitObject, SplitRepository>,
            GenericState>(builder: (BuildContext context, GenericState state) {
          if (state is LoadingState) {
            return const Loading();
          } else if (state is HasDataState) {
            final List<SplitObject> items = state.data as List<SplitObject>;
            final List<String> uids = widget.trip.accessUsers;
            final List<String> itemDocIDs =
                items.map((SplitObject e) => e.itemDocID).toList();
            print('itemDocIDs: $itemDocIDs');
            if (items.isNotEmpty) {
              return Column(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(45),
                            bottomRight: Radius.circular(45)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Expenses.',
                                  style: labelLarge(context),
                                ),
                                DropdownButton<String>(
                                  value: selectedCurrency,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCurrency = newValue!;
                                    });
                                  },
                                  items: currencies
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                            Text(
                              '\$${getTotalCost(items).toStringAsFixed(2)}',
                              style: headlineMedium(context),
                            ),
                            SizedBox(
                              height: SizeConfig.screenHeight * .125,
                              child: StreamBuilder<List<CostObjectModel>>(
                                stream: SplitService(itemDocIDs: itemDocIDs)
                                    .costDataCompleteList,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<CostObjectModel>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    final List<CostObjectModel>
                                        userCostDataList = snapshot.data!;
                                    print(
                                        'userCostDataList: ${userCostDataList[0]}');
                                    return ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: uids
                                          .map((String uid) =>
                                              PrepaidDetailsCard(
                                                items: userCostDataList
                                                    .where((CostObjectModel
                                                            item) =>
                                                        item.uid == uid)
                                                    .toList(),
                                                uid: uid,
                                              ))
                                          .toList(),
                                    );
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Loading();
                                  } else {
                                    return const ListTile(
                                      title: Text('No items have been split.'),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final SplitObject item = items[index];
                          return InkWell(
                            onLongPress: () {
                              if (userService.currentUserID ==
                                  item.purchasedByUID) {
                                SplitPackage().editSplitDialog(context, item);
                              }
                            },
                            onTap: () {
                              navigationService.navigateTo(
                                  SplitDetailsPageRoute,
                                  arguments: SplitDetailsArguments(
                                      splitObject: item, trip: widget.trip));
                            },
                            child: Card(
                              child: Container(
                                height: SizeConfig.screenHeight * .1,
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: SplitIconWidget(
                                        type: item.itemType,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: ListTile(
                                        title: Text(
                                          item.itemName,
                                          style: SizeConfig.tablet
                                              ? headlineLarge(context)
                                              : titleMedium(context)?.copyWith(
                                                  fontWeight: FontWeight.w600),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                            '\$${item.amountRemaining.toStringAsFixed(2)}  (${item.userSelectedList.length}pp)',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Cantata One',
                                                color: Colors.red)),
                                        trailing:
                                            const Icon(Icons.arrow_forward),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              );
            } else {
              return const ListTile(
                title: Text('No items have been split.'),
              );
            }
          } else {
            return const ListTile(
              title: Text('No items have been split.'),
            );
          }
        }),
      ),
    );
  }
}
