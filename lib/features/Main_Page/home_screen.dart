import 'package:flutter/material.dart';

import '../../models/recommended_model/recommended_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/theme/text_styles.dart';
import '../../size_config/size_config.dart';
import '../Main_Page/logic/logic.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _buildRowWithTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title,
          style: titleMedium(context)?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRecommendedContentModel(String content) {
    return SizedBox(
      height: SizeConfig.screenWidth * .6,
      child: FutureBuilder<List<RecommendedContentModel>>(
        future: getRecommendedContentModel(content),
        builder: (BuildContext context,
            AsyncSnapshot<List<RecommendedContentModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final RecommendedContentModel recommendedContent =
                    snapshot.data![index];
                return Container(
                  width: SizeConfig.screenWidth * .5,
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: recommendedContent.urlToImage == null ||
                                  (recommendedContent.urlToImage.isEmpty)
                              ? Image.asset(
                                  travelImage,
                                  fit: BoxFit.cover,
                                  height: SizeConfig.screenWidth * .45,
                                  width: SizeConfig.screenWidth * .45,
                                )
                              : Image.network(
                                  recommendedContent.urlToImage[getRandomIndex(
                                      recommendedContent.urlToImage)],
                                  fit: BoxFit.cover,
                                  height: SizeConfig.screenWidth * .45,
                                  width: SizeConfig.screenWidth * .45,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recommendedContent.name,
                          style: titleMedium(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: SizeConfig.screenWidth * .5,
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            travelImage,
                            fit: BoxFit.cover,
                            height: SizeConfig.screenWidth * .45,
                            width: SizeConfig.screenWidth * .45,
                          )),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Travel',
                            style: titleMedium(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // OutlinedButton(
              //     onPressed: () {navigationService.navigateTo(AddActivityRoute);},
              //     child: Text(
              //       'Create Activity',
              //       style: titleMedium(context)
              //           ?.copyWith(fontWeight: FontWeight.bold),
              //     )),
              OutlinedButton(
                  onPressed: () {
                    navigationService.navigateTo(AddNewTripRoute);
                  },
                  child: Text(
                    'Create Trip',
                    style: titleMedium(context)
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(height: 2, color: Colors.grey[300]),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildRowWithTitle('Activity Suggestions', context),
                Expanded(child: _buildRecommendedContentModel('activity')),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildRowWithTitle('Trip Suggestions', context),
                Expanded(child: _buildRecommendedContentModel('trip')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
