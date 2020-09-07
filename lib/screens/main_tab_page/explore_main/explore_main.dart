import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/loading.dart';
import 'package:travelcrew/services/api.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

class ExploreMain extends StatefulWidget {

  @override
  _ExploreMainState createState() => _ExploreMainState();
}

class _ExploreMainState extends State<ExploreMain> {
  final SearchBarController _searchBarController = SearchBarController();
  bool searching = false;
  bool _showPopup = false;
  var _countryName;

  @override
  Widget build(BuildContext context) {
//    var countries = APIService().getCountries();

    // TODO: implement build
  //   return Container(
  //     child: SearchBar(
  //       placeHolder: listCountries(),
  //       onSearch: RestCountries().getCountry,
  //       onItemFound: (Countries country, int index) {
  //         return ListTile(
  //           title: Text(country.name),
  //           subtitle: Text(country.currencies[0]),
  //         );
  //       }),
  //   );
  // }
    return Stack(
      children: <Widget>[
        Container(
          child: SearchBar(
              placeHolder: listCountries(),
              onSearch: RestCountries().getCountry,
              onItemFound: (Countries country, int index) {
                return ListTile(
                  title: Text(country.name),
                  subtitle: Text('Capital: ${country.capital}'),

                );
              }),
        ),
        _showPopup ? Column(
          children: <Widget>[
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            Container(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    'assets/images/travelPics.png',
                    height: 300,
                    width: 300,
                  ),
                ),
              ),
            ),
          ],
        ) : Visibility(
          visible: false,
          child: Text(''),
        ),
      ],
    );
  }



  Widget listCountries() {

    return Stack(
      children: [
        FutureBuilder(
          builder: (context, countries) {
            if (countries.hasData) {
              return ListView.builder(
                itemCount: countries.data.length,
                itemBuilder: (context, index) {
                  Countries country = countries.data[index];
                  return GestureDetector(
                    onLongPress: (){
                      setState(() {
                        _showPopup = true;
                        _countryName = country.name;

                      });
                    },
                    onLongPressEnd: (details){
                      setState(() {
                        _showPopup = false;

                      });
                    },
                    child: ListTile(
                      title: Text(country.name),
                      subtitle: Text('Capital: ${country.capital}'),
                      onTap: (){
                        // Covid19StatsByCountry().getStats(country.name);
                      },
                    ),
                  );
                },
              );
            } else {
              return Loading();
            }
          },
          future: APIService().getCountries(),
        ),
      ],
    );
  }

  Widget covid19Stats() {
    return FutureBuilder(
      builder: (context, stats) {
        return ListView.builder(
          itemCount: stats.data.length,
          itemBuilder: (context, index) {
            Covid19 stat = stats.data[index];
            return Column(
              children: <Widget>[
                // Widget to display the list of project
                Text('${stat.countryName}', style: TextStyle(fontSize: 16),),
                Text('Number of active cases: ${stat.activeCases}'),
                Text('New deaths: ${stat.newDeaths}')
              ],
            );
          },
        );
      },
      future: Covid19API().getStats(),
    );
  }

  Widget holidayList() {
    return FutureBuilder(
      builder: (context, holidays) {
        if (holidays.hasData) {
          return ListView.builder(
            itemCount: holidays.data.length,
            itemBuilder: (context, index) {
              Holiday holiday = holidays.data[index];
              return Column(
                children: <Widget>[
                  // Widget to display the list of project
                  Text('${holiday.name}', style: TextStyle(fontSize: 16),),
                  Text('Local Name: ${holiday.localName}'),
                  Text('Date: ${holiday.date}')
                ],
              );
            },
          );
        } else {
          return Loading();
        }
      },
      future: PublicHolidayAPI().getHolidays('US'),
    );
  }


}



