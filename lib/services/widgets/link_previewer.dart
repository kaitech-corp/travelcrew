import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

class ViewAnyLink extends StatefulWidget {
  const ViewAnyLink({
    Key? key,
    required this.link,
    required this.function,
}) : super(key: key);

  final String link;
  final Function() function;

  @override
  _ViewAnyLinkState createState() => _ViewAnyLinkState();
}

class _ViewAnyLinkState extends State<ViewAnyLink> {

  @override
  Widget build(BuildContext context) {
    return AnyLinkPreview(
      link: widget.link,
      bodyStyle: TextStyle(color: Colors.blueGrey),
      onTap: widget.function,
    );
  }
}

