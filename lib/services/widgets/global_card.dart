import 'package:flutter/material.dart';

class GlobalCard extends StatelessWidget{

  const GlobalCard({super.key, this.widget});
  final Widget? widget;


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      elevation: 10,
      shadowColor: Colors.black26,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Colors.blue.shade50,
                  Colors.lightBlueAccent.shade200
                ]
            ),
          ),
          child: widget),
    );
  }

}
