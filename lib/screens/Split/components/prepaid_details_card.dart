import 'package:flutter/material.dart';

import '../../../../services/theme/text_styles.dart';
import '../../../../size_config/size_config.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../Profile/logic/logic.dart';
import '../logic/split_functions.dart';



class PrepaidDetailsCard extends StatelessWidget {
  const PrepaidDetailsCard({
    super.key,
    required this.items,
    required this.uids,
  });

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
            return FutureBuilder<UserPublicProfile>(
              builder: (BuildContext context,
                  AsyncSnapshot<UserPublicProfile> userData) {
                if (userData.hasData) {
                  final UserPublicProfile user = userData.data!;
                  return Container(
                    padding: EdgeInsets.all(SizeConfig.defaultPadding),
                    height: SizeConfig.screenWidth * .35,
                    width: SizeConfig.screenWidth * .5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${user.displayName} Owes: ',
                          style: SizeConfig.tablet
                              ? headlineMedium(context)
                              : titleMedium(context),
                        ),
                        Text(
                          '\$${userDetails[index].total.toStringAsFixed(2)}',
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
              future: specificUserPublicProfile(userDetails[index].uid!),
            );
          }),
    );
  }
}
