import 'package:flutter/material.dart';

class AppBarGradient extends StatelessWidget {
  const AppBarGradient({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[900],
              Colors.lightBlueAccent
            ]
        ),
        boxShadow: [
          const BoxShadow(
            color: Colors.black,
            blurRadius: 10.0,
          ),
          const BoxShadow(
            color: Colors.blueAccent,
            blurRadius: 10.0,
          ),
        ],
      ),
    );
  }
}