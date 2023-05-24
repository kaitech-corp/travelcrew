import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';
import '../../../repositories/split_repository.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import 'components/prepaid_details_card.dart';
import 'logic/split_functions.dart';
import 'split_package.dart';

/// Split Page
class SplitPage extends StatefulWidget {
  const SplitPage({
    Key? key,
    required this.trip,
  }) : super(key: key);
  final Trip trip;

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  late GenericBloc<SplitObject, SplitRepository> bloc;

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
            final List<String> uids = listOfUserID(items);
            if (items.isNotEmpty) {
              final double total = calculateTotal(items);
              return Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(45),
                            bottomRight: Radius.circular(45)),
                      ),
                      width: SizeConfig.screenWidth,
                      padding: EdgeInsets.all(SizeConfig.defaultPadding),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Total expenses.',
                            style: headlineSmall(context),
                          ),
                          Text(
                            '\$$total',
                            style: headlineLarge(context),
                          ),
                          Expanded(
                            child: PrepaidDetailsCard(
                              items: items,
                              uids: uids,
                            ),
                          )
                        ],
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
                                            : headlineSmall(context),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                          '\$${item.amountRemaining.toStringAsFixed(2)}  (${item.userSelectedList.length}pp)',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Cantata One',
                                              color: Colors.red)),
                                      trailing: const Icon(Icons.arrow_forward),
                                    ),
                                  ),
                                ],
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
