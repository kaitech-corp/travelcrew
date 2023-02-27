import 'package:flutter/material.dart';


import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';
import '../../../services/database.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';
import 'split_functions.dart';

class PrepaidDetailsCard extends StatelessWidget {
  const PrepaidDetailsCard({
    Key? key,
    required this.items,
    required this.uids,
  }) : super(key: key);

  final List<SplitObject> items;
  final List<String> uids;

  @override
  Widget build(BuildContext context) {
    final List<UserPurchaseDetails> userDetails =
    calculateTotalPerUser(uids, items);
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
                builder: (BuildContext context,
                    AsyncSnapshot<UserPublicProfile> userData) {
                  if (userData.hasData) {
                    final UserPublicProfile user = userData.data!;
                    return Container(
                      padding: EdgeInsets.all(SizeConfig.defaultPadding),
                      height: SizeConfig.screenWidth * .35,
                      width: SizeConfig.screenWidth * .5,
                      child: Column(
                        children: <Widget>[
                          Text(
                            user.displayName,
                            style: SizeConfig.tablet
                                ? headlineMedium(context)
                                : titleMedium(context),
                          ),
                          Text(
                            'Prepaid: \$${userDetails[index].total.toStringAsFixed(2)}',
                            style: SizeConfig.tablet
                                ? headlineMedium(context)
                                : titleMedium(context),
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
