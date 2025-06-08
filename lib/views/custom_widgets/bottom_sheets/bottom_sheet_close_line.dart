import 'package:flutter/material.dart';
class BottomSheetCloseLine extends StatelessWidget {
  const BottomSheetCloseLine({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      height: 5.0,
      width: 50.0,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
