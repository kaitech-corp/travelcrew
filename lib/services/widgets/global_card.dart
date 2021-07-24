import 'package:flutter/material.dart';

class GlobalCard extends StatelessWidget{
  final Widget widget;

  const GlobalCard({Key key, this.widget}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      elevation: 10,
      shadowColor: Colors.black26,
      child: widget,
    );
  }

}