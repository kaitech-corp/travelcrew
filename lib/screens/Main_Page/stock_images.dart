import 'package:flutter/material.dart';

import '../../services/widgets/link_previewer.dart';
import '../../size_config/size_config.dart';
import '../Activities/logic/links.dart';

class StockImageViewer extends StatelessWidget {
  const StockImageViewer({ super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> linkCategories = [
      'seminarLinks',
      'trainingLinks',
      'conferenceLinks',
      'salesLinks',
      'exploringLinks',
      'yogaLinks',
      'festivalLinks',
      'concertLinks',
      'fitnessLinks',
      'spaLinks',
      'comedyLinks',
      'campingLinks',
      'fishingLinks',
      'beachLinks',
      'wildlifeLinks',
      'outdoorsLinks',
      'workingLinks',
      'cookingLinks',
      'homeLinks',
      'petcareLinks',
      'familyLinks',
      'foodLinks',
      'kidLinks',
      'gardenLinks',
      'funLinks',
    ];
    const List<List<String>> linkLists = <List<String>>[
      seminarLinks,
      trainingLinks,
      conferenceLinks,
      salesLinks,
      exploringLinks,
      yogaLinks,
      festivalLinks,
      concertLinks,
      fitnessLinks,
      spaLinks,
      comedyLinks,
      campingLinks,
      fishingLinks,
      beachLinks,
      wildlifeLinks,
      outdoorsLinks,
      workingLinks,
      cookingLinks,
      homeLinks,
      petcareLinks,
      familyLinks,
      foodLinks,
      kidLinks,
      gardenLinks,
      funLinks,
    ];
    return DefaultTabController(
      length: linkLists.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock Images'),
          bottom: TabBar(
            isScrollable: true,
            tabs: linkLists.map((List<String> linkList) {
              return Tab(text: linkCategories[linkLists.indexOf(linkList)]);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: linkLists.map((List<String> linkList) {
            return SingleChildScrollView(
              child: Column(
                children: linkList.map((String link) {
                  return SizedBox(
                    height: SizeConfig.screenHeight * .275,
                    child: ViewAnyLink(
                      hash: link.hashCode,
                      link: link,
                      function: () {},
                      multiMediaonly: true,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
