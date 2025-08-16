import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
class PhotoViewWidget extends StatelessWidget {
  const PhotoViewWidget({
    super.key,
    required this.imageUrl,
    required this.sourceType,
    this.viewCloseButton = true,
  });
  final String imageUrl;
  final ImageSourceType sourceType;
  final bool viewCloseButton;
  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    switch (sourceType) {
      case ImageSourceType.network:
        imageProvider = CachedNetworkImageProvider(
          imageUrl,
          headers: const {
            // HttpHeaders.authorizationHeader:
            //     'Bearer ${supabase.auth.currentSession?.accessToken}'
          },
        );
        break;
      case ImageSourceType.file:
        imageProvider = FileImage(File(imageUrl));
        break;
      case ImageSourceType.asset:
        imageProvider = AssetImage(imageUrl);
        break;
    }
    return Stack(
      children: [
        PhotoView(
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Center(child: Text('Error loading image')),
          loadingBuilder:
              (context, event) => Center(
                child: CircularProgressIndicator(
                  value:
                      event == null
                          ? null
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                ),
              ),
          imageProvider: imageProvider,
        ),
        if (viewCloseButton)
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }
}
enum ImageSourceType { network, file, asset }
void previewImageDialogue({
  required String imageUrl,
  required ImageSourceType sourceType,
  double? width,
  double? height,
}) {
  showDialog(
    context: Get.context!,
    builder:
        (context) => Dialog(
          insetPadding: EdgeInsets.zero,
          child: SizedBox(
            width: width ?? Get.width,
            height: height ?? Get.height,
            child: PhotoViewWidget(imageUrl: imageUrl, sourceType: sourceType),
          ),
        ),
  );
}
