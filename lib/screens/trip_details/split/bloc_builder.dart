import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';

import '../../../repositories/split_repository.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import 'split_package.dart';

/// Split Bloc Builder
class SplitBlocBuilder extends StatefulWidget {
  const SplitBlocBuilder({
    Key? key,
    required this.trip,
  }) : super(key: key);
  final Trip trip;

  @override
  _SplitBlocBuilderState createState() => _SplitBlocBuilderState();
}

class _SplitBlocBuilderState extends State<SplitBlocBuilder> {
  late GenericBloc<SplitObject, SplitRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<SplitObject, SplitRepository>>(context);
    bloc.add(LoadingGenericData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<GenericBloc<SplitObject, SplitRepository>,
            GenericState>(builder: (BuildContext context, GenericState state) {
          if (state is LoadingState) {
            return Loading();
          } else if (state is HasDataState) {
            final List<SplitObject> items = state.data as List<SplitObject>;
            final List<String> uids = [];
            if (items.isNotEmpty) {
              double total = 0.00;
              for (final SplitObject item in items) {
                total += item.itemTotal!;
                if (!uids.contains(item.purchasedByUID)) {
                  uids.add(item.purchasedByUID!);
                }
              }
              return Column(
                children: [
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
                        children: [
                          Text(
                            'Total expenses.',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            '\$$total',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          Expanded(
                            child: QuickDataCards(
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
                                      splitObject: item,
                                      purchasedByUID: item.purchasedByUID!,
                                      trip: widget.trip));
                            },
                            child: Container(
                              height: SizeConfig.screenHeight * .1,
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SplitIconWidget(
                                      type: item.itemType!,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: ListTile(
                                      title: Text(
                                        item.itemName!,
                                        style: SizeConfig.tablet
                                            ? Theme.of(context)
                                                .textTheme
                                                .headline4
                                            : Theme.of(context)
                                                .textTheme
                                                .headline6,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                          '\$${item.amountRemaining?.toStringAsFixed(2) ?? item.itemTotal!.toStringAsFixed(2)}  (${item.userSelectedList!.length}pp)',
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

class QuickDataCards extends StatelessWidget {
  const QuickDataCards({
    Key? key,
    required this.items,
    required this.uids,
  }) : super(key: key);

  final List<SplitObject> items;
  final List<String> uids;

  List<UserPurchaseDetails> calculateTotalPerUser() {
    final List<UserPurchaseDetails> calculatedList = [];
    for (final String element in uids) {
      calculatedList.add(UserPurchaseDetails(uid: element, total: 0.00));
    }

    for (final SplitObject item in items) {
      for (final UserPurchaseDetails object in calculatedList) {
        if (object.uid == item.purchasedByUID) {
          // object.total += item.itemTotal!;
        }
      }
    }
    return calculatedList;
  }

  @override
  Widget build(BuildContext context) {
    final List<UserPurchaseDetails> userDetails = calculateTotalPerUser();
    return SizedBox(
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenWidth * .3,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: userDetails.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.transparent,
              elevation: 0,
              child: StreamBuilder<UserPublicProfile>(
                builder: (BuildContext context, AsyncSnapshot<UserPublicProfile> userData) {
                  if (userData.hasData) {
                    final UserPublicProfile user =
                        userData.data as UserPublicProfile;
                    return Container(
                      padding: EdgeInsets.all(SizeConfig.defaultPadding),
                      height: SizeConfig.screenWidth * .35,
                      width: SizeConfig.screenWidth * .5,
                      child: Column(
                        children: [
                          Text(
                            user.displayName,
                            style: SizeConfig.tablet
                                ? Theme.of(context).textTheme.headline5
                                : Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            'Prepaid: \$${userDetails[index].total!.toStringAsFixed(2)}',
                            style: SizeConfig.tablet
                                ? Theme.of(context).textTheme.headline5
                                : Theme.of(context).textTheme.subtitle1,
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height: 2,
                            color: Colors.black,
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.all(SizeConfig.defaultPadding),
                      height: SizeConfig.screenWidth * .35,
                      width: SizeConfig.screenWidth * .4,
                      child: Column(
                        children: const <Widget>[
                          Text('Name: N/A'),
                          Text(r'Paid: $0.00'),
                        ],
                      ),
                    );
                  }
                },
                stream: DatabaseService(userID: userDetails[index].uid)
                    .specificUserPublicProfile,
              ),
            );
          }),
    );
  }
}
