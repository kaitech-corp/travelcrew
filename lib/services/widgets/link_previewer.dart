import 'dart:async';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class ViewAnyLink extends StatefulWidget {
  const ViewAnyLink({
    super.key,
    required this.hash,
    required this.link,
    required this.function,
    required this.multiMediaonly,
  });
  final int hash;
  final bool multiMediaonly;
  final String link;
  final Function() function;

  @override
  State<ViewAnyLink> createState() => _ViewAnyLinkState();
}

class _ViewAnyLinkState extends State<ViewAnyLink> {
  bool showErrorText = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (widget.link.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(getActivityImage(widget.hash),
            fit: BoxFit.fill),
      );
    }

    return FutureBuilder<dynamic>(
      future: checkMetadata(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final dynamic metadata = snapshot.data;
          if (metadata != null) {
            return AnyLinkPreview(
              link: widget.link,
              bodyStyle: const TextStyle(color: Colors.blueGrey),
              onTap: widget.function,
              errorImage: travelImage,
              displayDirection: widget.multiMediaonly
                  ? UIDirection.uiDirectionHorizontal
                  : UIDirection.uiDirectionVertical,
              bodyMaxLines: 2,
            );
          }
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(getActivityImage(widget.hash), fit: BoxFit.fill),
        );
      },
    );
  }

  Future<dynamic> checkMetadata() {
    return AnyLinkPreview.getMetadata(link: widget.link);
  }

  Widget showErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.error, color: Colors.red),
        const SizedBox(height: 8),
        Text(errorMessage ?? 'Error loading link'),
      ],
    );
  }
}

Future<bool> hasMetadata(String? link) async {
  if (link == null || link.isEmpty) {
    return false;
  } else {
    Metadata? metadata = await AnyLinkPreview.getMetadata(link: link);
    return metadata != null;
  }
}
