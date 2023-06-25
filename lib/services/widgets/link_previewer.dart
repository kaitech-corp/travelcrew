import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class ViewAnyLink extends StatefulWidget {
  const ViewAnyLink({
    Key? key,
    required this.link,
    required this.function,
  }) : super(key: key);

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
    return FutureBuilder(
      future: loadLinkPreview(),
      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return showErrorWidget();
        } else {
          return AnyLinkPreview(
            link: widget.link,
            bodyStyle: const TextStyle(color: Colors.blueGrey),
            onTap: widget.function,
            errorImage: travelImage,
          );
        }
      },
    );
  }

  Future<void> loadLinkPreview() async {
    try {
      AnyLinkPreview.isValidLink(widget.link);
    } catch (error) {
      setState(() {
        showErrorText = true;
        errorMessage = error.toString();
      });
    }
  }

  Widget showErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red),
        const SizedBox(height: 8),
        Text(errorMessage ?? 'Error loading link'),
      ],
    );
  }
}
