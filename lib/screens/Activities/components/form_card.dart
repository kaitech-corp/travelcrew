import 'package:flutter/material.dart';

import '../../../size_config/size_config.dart';

class FormCard extends StatelessWidget {
  const FormCard({
    required this.child,
    this.size,
    super.key,
  });
  final Widget child;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        height: size ?? SizeConfig.screenHeight * .3,
        width: SizeConfig.screenWidth,
        child: Row(children: <Widget>[
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15)),
                color: Colors.blue),
            height: SizeConfig.screenHeight * .3,
            width: SizeConfig.blockSizeHorizontal * 4,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(width: SizeConfig.screenWidth * .8, child: child),
          ),
        ]),
      ),
    );
  }
}
