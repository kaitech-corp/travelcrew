import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class ProgressBarWidget extends StatelessWidget {

  final currentValue;
  final maxValue;

  const ProgressBarWidget({Key key, this.currentValue, this.maxValue}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FAProgressBar(
      currentValue: currentValue,
      maxValue: maxValue,
      animatedDuration:
      const Duration(milliseconds: 1500),
      displayText: '',
      border: Border.all(color: Colors.grey),
      progressColor: Colors.green,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    );
  }

}