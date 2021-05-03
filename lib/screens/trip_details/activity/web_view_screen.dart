import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../services/widgets/loading.dart';

class WebViewScreen extends StatefulWidget {
  final url;
  final key;
  WebViewScreen({this.url, this.key});

  @override
  _WebViewScreenState createState() => _WebViewScreenState(this.url,this.key);

}
  class _WebViewScreenState extends State<WebViewScreen>{

  var _url;
  var _key;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  _WebViewScreenState(this._url, this._key);
  bool loading = true;

  changeState() {
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
            key: _key,
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: _url,
            onPageFinished: (done){
              setState(() {
              loading = false;
            });},
          ),
          loading ? Center(child: Loading()) : Stack(),
        ],
      ),
    );
  }

  }
