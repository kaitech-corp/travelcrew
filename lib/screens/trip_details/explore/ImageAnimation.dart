import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../models/trip_model.dart';
import '../../../size_config/size_config.dart';

final double defaultSize = SizeConfig.defaultSize;

/// Trip image animation of explore page
class CustomShape2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double height = size.height;
    final double width = size.width;
    path.lineTo(0, height - 0);
    path.quadraticBezierTo(width / 2, height, width, height - 0);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CustomHangingImage extends StatelessWidget {
  const CustomHangingImage(
      {Key? key, required this.urlToImage, required this.height})
      : super(key: key);

  final String urlToImage;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape2(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height, //150
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(urlToImage), fit: BoxFit.cover)),
      ),
    );
  }
}

class ImageAnimation extends StatefulWidget {
  const ImageAnimation({
    Key? key,
    required this.trip,
    required this.expandController,
  }) : super(key: key);
  final Trip trip;
  final ExpandableController expandController;

  @override
  State<ImageAnimation> createState() => _ImageAnimationState();
}

class _ImageAnimationState extends State<ImageAnimation> {
  double _height = SizeConfig.screenHeight * .4;
  @override
  void initState() {
    super.initState();
    widget.expandController.addListener(onExpand);
  }

  void onExpand() {
    if (mounted) {
      setState(() {
        if (widget.expandController.expanded) {
          _height = defaultSize * 15.0;
        } else {
          _height = SizeConfig.screenHeight * .4;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.trip.urlToImage,
      transitionOnUserGestures: true,
      child: CustomHangingImage(
        urlToImage: widget.trip.urlToImage,
        height: _height,
      ),
    );
  }
}
