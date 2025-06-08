import 'package:flutter/material.dart';

import '../../../utils/app_images.dart'; // Replace with your actual import

class HeartToggleWidget extends StatelessWidget {
  final bool isLiked;
  final Function()? onLiked;
  const HeartToggleWidget({super.key, required this.isLiked, this.onLiked});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLiked,
      child: Image.asset(
        isLiked ? AppImages.kHeartFilledIcon : AppImages.kHeartUnFilledIcon,
        scale: 4,
      ),
    );
  }
}
