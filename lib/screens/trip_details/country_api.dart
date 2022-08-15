

import 'package:flutter/material.dart';

import '../../models/custom_objects.dart';

class CountryAPI extends StatelessWidget {

  final Countries countries;

  CountryAPI({required this.countries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country List'),
      ),
      body: Container(
//        child: StreamBuilder(
        )
//      ),
    );
  }
}