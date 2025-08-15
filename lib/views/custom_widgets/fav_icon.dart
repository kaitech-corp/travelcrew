import 'package:flutter/material.dart';
class FavIcon extends StatelessWidget {
  final bool isFavorite;
  final Function()? onTap;
  const FavIcon({super.key, required this.isFavorite, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 27.47,
        height: 27.47,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey,
          size: 18.0,
        ),
      ),
      // AnyImageView(
      //   width: 26.47,
      //   height: 26.47,
      //   isCircle: true,
      //   url: isFavorite ? AppImages.kFaveIcon : AppImages.kUnFavoriteIcon,
      //   fileType: SourceType.asset,
      // ),
    );
  }
}