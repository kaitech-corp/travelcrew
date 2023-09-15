import 'package:flutter/material.dart';

class AppBarGradient extends StatelessWidget {
  const AppBarGradient({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.blue[900]!,
              Colors.lightBlueAccent
            ]
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 10.0,
          ),
          BoxShadow(
            color: Colors.blueAccent,
            blurRadius: 10.0,
          ),
        ],
      ),
    );
  }
}
