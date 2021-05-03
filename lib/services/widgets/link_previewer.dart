import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:travelcrew/size_config/size_config.dart';

class LinkPreviewer extends StatelessWidget {
  const LinkPreviewer({
    Key key,
    @required this.link,
  }) : super(key: key);

  final String link;

  @override
  Widget build(BuildContext context) {
    return LinkPreview(
      text: link,
      width: SizeConfig.screenWidth,
    );
  }
}