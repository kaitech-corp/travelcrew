import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../loading.dart';

class WebViewScreen extends StatefulWidget {
  final url;
  final key;
  WebViewScreen(this.url,this.key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState(this.url,this.key);
// TODO: implement createState

}
  class _WebViewScreenState extends State<WebViewScreen>{

  var _url;
  var _key;

  _WebViewScreenState(this._url, this._key);
  bool loading = true;

  changeState() {
    setState(() {
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Crew'),
      ),
      body: Column(
        children: <Widget>[
          loading ? Center(child: Loading(),) : Container(),
          Expanded(
            child:  WebView(
              key: _key,
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: _url,
              onPageFinished: (done){
                setState(() {
                loading = false;
              });},
            ),
          ),
        ],
      ),
    );
  }

  }
