// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:travelcrew/models/custom_objects.dart';
// import 'package:travelcrew/loading.dart';
// import 'package:travelcrew/services/api.dart';
// import 'package:flappy_search_bar/flappy_search_bar.dart';
//
// class ExploreMain extends StatefulWidget {
//
//   @override
//   _ExploreMainState createState() => _ExploreMainState();
// }
//
// class _ExploreMainState extends State<ExploreMain> {
//   bool searching = false;
//   bool _showPopup = false;
//   var _countryName;
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Stack(
//       children: <Widget>[
//         Container(
//           child: SearchBar(
//             hintText: 'Covid19 statistics by country',
//               placeHolder: listCountries(),
//               onSearch: RestCountries().getCountry,
//               onItemFound: (Countries country, int index) {
//                 return GestureDetector(
//                   onTap: (){
//                     setState(() {
//                       _showPopup = true;
//                       _countryName = country.name;
//                     });
//                   },
//
//                   child: ListTile(
//                     title: Text(country.name),
//                     subtitle: Text('Capital: ${country.capital}'),
//                   ),
//                 );
//               }),
//         ),
//         _showPopup ? Column(
//           children: <Widget>[
//             BackdropFilter(
//               filter: ImageFilter.blur(
//                 sigmaX: 5.0,
//                 sigmaY: 5.0,
//               ),
//               child: Container(
//                 color: Colors.white.withOpacity(0.6),
//               ),
//             ),
//             Container(
//               alignment: Alignment.centerLeft,
//               padding: const EdgeInsets.only(top: 100),
//               child: Center(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10.0),
//                   child: Container(
//                     child: Card(
//                       color: Colors.blueAccent[200],
//                       child: covidStatsByCountry(_countryName),
//                     ),
//                     height: 200,
//                     width: 300,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ) : Visibility(
//           visible: false,
//           child: Text(''),
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget listCountries() {
//
//     return Stack(
//       children: [
//         FutureBuilder(
//           builder: (context, countries) {
//             if (countries.hasData) {
//               return ListView.builder(
//                 itemCount: countries.data.length,
//                 itemBuilder: (context, index) {
//                   Countries country = countries.data[index];
//                   return GestureDetector(
//                     onTap: (){
//                       setState(() {
//                         _showPopup = true;
//                         _countryName = country.name;
//                       });
//                     },
//                     child: ListTile(
//                       title: Text(country.name),
//                       subtitle: Text('Capital: ${country.capital}'),
//                       onTap: (){
//                         setState(() {
//                           _showPopup = true;
//                           _countryName = country.name;
//                         });
//                       },
//                     ),
//                   );
//                 },
//               );
//             } else {
//               return Loading();
//             }
//           },
//           future: APIService().getCountries(),
//         ),
//       ],
//     );
//   }
//
//   Widget covidStatsByCountry(String country) {
//     return FutureBuilder(
//       builder: (context, stats) {
//         if(stats.hasData) {
//               Covid19_2 stat = stats.data;
//               return InkWell(
//                 splashColor: Colors.blueAccent,
//                 onTap: (){
//                   setState(() {
//                     _showPopup = false;
//                   });
//                 },
//                 child: Column(
//                   children: [
//                     ListTile(
//                       title: Text('${stat.countryName}', style: TextStyle(fontSize: 24, color: Colors.white),),
//                       subtitle: Text('Last Updated: ${stat.lastUpdate}', style: TextStyle(fontSize: 12, color: Colors.white),),
//                     ),
//                     Text('Number of active cases: ${stat.activeCases}', style: TextStyle(fontSize: 16, color: Colors.white),textAlign: TextAlign.left),
//                     Text('Total cases: ${stat.totalCases}', style: TextStyle(fontSize: 16, color: Colors.white),textAlign: TextAlign.left),
//                     Text('Total Recovered: ${stat.totalRecovered}', style: TextStyle(fontSize: 16, color: Colors.white),textAlign: TextAlign.left),
//                     Text('Total Deaths: ${stat.totalDeaths}', style: TextStyle(fontSize: 16, color: Colors.white),textAlign: TextAlign.left),
//                   ],
//                 ),
//               );
//         } else {
//           return Loading();
//         }
//       },
//       future: Covid19StatsByCountry().getStats(country),
//     );
//   }
//
// }
//
//
//
