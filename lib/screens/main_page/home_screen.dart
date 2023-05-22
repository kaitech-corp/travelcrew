import 'package:flutter/material.dart';

import '../../models/recommended_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/tc_functions.dart';
import '../../services/theme/text_styles.dart';
import '../../size_config/size_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _buildRowWithTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: titleMedium(context)?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRecommendedContent(String content) {
    return SizedBox(
      height: SizeConfig.screenWidth * .6,
      child: FutureBuilder<List<RecommendedContent>>(
        future: DatabaseService().getRecommendedContent(content),
        builder: (BuildContext context,
            AsyncSnapshot<List<RecommendedContent>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final RecommendedContent recommendedContent =
                    snapshot.data![index];
                return Container(
                  width: SizeConfig.screenWidth * .5,
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
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
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            recommendedContent.name,
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
          } else {
            return const Center(child: CircularProgressIndicator());
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
              OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    'Custom Activity',
                    style: titleMedium(context)?.copyWith(fontWeight: FontWeight.bold),
                  )),
              OutlinedButton(
                  onPressed: () {},
                  child: Text('Custom Trip', style: titleMedium(context)?.copyWith(fontWeight: FontWeight.bold),)),
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
              children: [
                _buildRowWithTitle('Plan an Activity', context),
                _buildRecommendedContent('activity'),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRowWithTitle('Plan a Trip', context),
                _buildRecommendedContent('trip'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
