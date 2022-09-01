import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../services/widgets/loading.dart';

class WebViewScreen extends StatefulWidget {

  const WebViewScreen({Key? key, required this.url,}) : super(key: key);
  final String url;


  @override
  _WebViewScreenState createState() => _WebViewScreenState();

}
  class _WebViewScreenState extends State<WebViewScreen>{

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }
  bool loading = true;

  void changeState() {
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Crew',style: Theme.of(context).textTheme.headline3,),
      ),
      body:
      Stack(
        children: [
          WebView(
            key: widget.key,
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: widget.url,
            onPageFinished: (String done){
              setState(() {
              loading = false;
            });},
          ),
          if (loading) Center(child: Loading()) else Stack(),
        ],
      ),
    );
  }

  }
