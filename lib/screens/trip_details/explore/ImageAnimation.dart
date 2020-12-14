import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/size_config/size_config.dart';

final double defaultSize = SizeConfig.defaultSize;

class CustomShape2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double height = size.height;
    double width = size.width;
    path.lineTo(0, height - 100);
    path.quadraticBezierTo(width / 2, height, width, height - 100);
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
  const CustomHangingImage({
    Key key,
    this.urlToImage, this.height
  }) : super(key: key);

  final urlToImage;
  final height;


  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape2(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        height: height, //150
        // color: Color(0xAA2D3D49),
        decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(urlToImage),
                fit: BoxFit.cover)
        ),
      ),
    );
  }
}

class ImageAnimation extends StatefulWidget{
  final Trip tripDetails;
  final expandController;
  final expandController2;
  final expandController3;
  const ImageAnimation({Key key, this.tripDetails, this.expandController, this.expandController2, this.expandController3}) : super(key: key);

  @override
  _ImageAnimationState createState() => _ImageAnimationState();
}

class _ImageAnimationState extends State<ImageAnimation> {

    double _height = SizeConfig.screenHeight*.4;
    @override
    void initState() {
      super.initState();
      widget.expandController.addListener(onExpand);
      widget.expandController2.addListener(onExpand);
      widget.expandController3.addListener(onExpand);
    }


    onExpand(){
      if(mounted){
      setState(() {
        if (widget.expandController.expanded ||
            widget.expandController2.expanded ||
            widget.expandController3.expanded) {
          _height = defaultSize.toDouble() * 15.0;
        } else {
          _height = SizeConfig.screenHeight*.4;
        }
      });
    }
  }

    @override
    Widget build(BuildContext context) {
      return Hero(
        tag: widget.tripDetails.urlToImage,
        transitionOnUserGestures: true,
        child: CustomHangingImage(urlToImage: widget.tripDetails.urlToImage,height: _height,),
      );
    }
  }

