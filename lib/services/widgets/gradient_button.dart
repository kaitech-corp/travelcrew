import 'package:flutter/material.dart';
import '../constants/constants.dart';

class GradientButton extends StatelessWidget {

  const GradientButton(
      {Key? key, this.width, this.height, this.onPressed, this.text, this.icon})
      : super(key: key);
  final double? width;
  final double? height;
  final Function()? onPressed;
  final Text? text;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, canvasColor,],
          // colors: [Colors.greenAccent, Color(0xff8f93ea)],
        ),
      ),
      child: MaterialButton(
          onPressed: onPressed,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                text!,
                icon!,
              ],
            ),
          )),
    );
  }
}