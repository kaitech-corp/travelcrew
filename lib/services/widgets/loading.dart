import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../size_config/size_config.dart';

class Loading extends StatelessWidget{
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      color: Colors.white,
      child: const Center(
        child: SpinKitChasingDots(
          color: Colors.blue,
          duration: Duration(seconds: 5),
        ),
      ),
    );
  }
}
