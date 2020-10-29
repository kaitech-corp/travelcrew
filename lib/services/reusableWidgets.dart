import 'package:flutter/material.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';

class CustomShape extends CustomClipper<Path> {
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

class ImageBanner extends StatelessWidget{
  final String _assetPath;

  ImageBanner(this._assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height * .33,
        ),
        decoration: BoxDecoration(color: Colors.grey),
        child: Image.asset(_assetPath,
          fit: BoxFit.fill,
        ));
  }
}

class TimePickers extends StatefulWidget{


  @override
  _TimePickersState createState() => _TimePickersState();
}

class _TimePickersState extends State<TimePickers> {

  String get _labelTextTimeStart {
    String _startTime = timeStart.format(context);
    startTime.value = _startTime;
    return _startTime;
  }
  String get _labelTextTimeEnd {
    String _endTime = timeEnd.format(context);
    endTime.value = _endTime;
    return endTime.value;
  }

  Future<void> showTimePickerStart(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: timeStart,
    );
    if (picked != null && picked != timeStart) {
      setState(() {
        timeStart = picked;
      });
    }
  }
  Future<void> showTimePickerEnd(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: timeEnd,
    );
    if (picked != null && picked != timeEnd) {
      setState(() {
        timeEnd = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(_labelTextTimeStart,style: Theme.of(context).textTheme.subtitle1,),
//                                SizedBox(height: 16),
              ButtonTheme(
                minWidth: 150,
                child: RaisedButton(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Start Time',
                  ),
                  onPressed: () async {
                    showTimePickerStart(context);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(_labelTextTimeEnd,style: Theme.of(context).textTheme.subtitle1,),
//                                SizedBox(height: 16),
              ButtonTheme(
                minWidth: 150,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'End Time',
                  ),
                  onPressed: () {
                    showTimePickerEnd(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedClipRRect extends StatelessWidget {
  const AnimatedClipRRect({
    @required this.duration,
    this.curve = Curves.linear,
    @required this.borderRadius,
    @required this.child,
  })  : assert(duration != null),
        assert(curve != null),
        assert(borderRadius != null),
        assert(child != null);

  final Duration duration;
  final Curve curve;
  final BorderRadius borderRadius;
  final Widget child;

  static Widget _builder(
      BuildContext context, BorderRadius radius, Widget child) {
    return ClipRRect(borderRadius: radius, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<BorderRadius>(
      duration: duration,
      curve: curve,
      tween: BorderRadiusTween(begin: BorderRadius.zero, end: borderRadius),
      builder: _builder,
      child: child,
    );
  }
}