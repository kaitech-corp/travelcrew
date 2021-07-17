import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:travelcrew/size_config/size_config.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_preview/flutter_link_preview.dart';

class LinkPreviewer extends StatefulWidget {
  const LinkPreviewer({
    Key key,
    @required this.link,
  }) : super(key: key);

  final String link;

  @override
  _LinkPreviewerState createState() => _LinkPreviewerState();
}

class _LinkPreviewerState extends State<LinkPreviewer> {
  Map<String, PreviewData> data2 = {};

  @override
  Widget build(BuildContext context) {
    return LinkPreview(
      text: widget.link,
      width: SizeConfig.screenWidth,
      enableAnimation: true,
      onPreviewDataFetched: (data){
        setState(() {
          data2 = {
            ...data2,
            widget.link: data,
          };
        });
      },
      previewData: data2[0],
    );
  }
}

class FlutterLinkView extends StatelessWidget{

  const FlutterLinkView({
    Key key,
    @required this.link,
  }) : super(key: key);

  final String link;

  @override
  Widget build(BuildContext context) {
    return FlutterLinkPreview(
      key: ValueKey(link),
      url: link,
      builder: (info) {
        if (info == null) return const SizedBox();
        if (info is WebImageInfo) {
          return Image.network(
            info.image,
            fit: BoxFit.contain,
          );
        }

        final WebInfo webInfo = info;
        if (!WebAnalyzer.isNotEmpty(webInfo.title)) return const SizedBox();
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFF0F1F2),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image.network(
                        webInfo.icon ?? "",
                        fit: BoxFit.contain,
                        width: 30,
                        height: 30,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.link);
                        },
                      ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      webInfo.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (WebAnalyzer.isNotEmpty(webInfo.description)) ...[
                const SizedBox(height: 8),
                Text(
                  webInfo.description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (WebAnalyzer.isNotEmpty(webInfo.image)) ...[
                const SizedBox(height: 8),
                Image.network(
                  webInfo.image,
                  fit: BoxFit.contain,
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}
