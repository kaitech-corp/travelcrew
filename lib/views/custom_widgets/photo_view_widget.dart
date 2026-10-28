import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:travel_crew/services/private_photo_service.dart';

class PhotoViewWidget extends StatefulWidget {
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
  State<PhotoViewWidget> createState() => _PhotoViewWidgetState();
}

class _PhotoViewWidgetState extends State<PhotoViewWidget> {
  Future<Uint8List>? _privateBytes;

  @override
  void initState() {
    super.initState();
    _privateBytes = _loadPrivate();
  }

  @override
  void didUpdateWidget(covariant PhotoViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.sourceType != widget.sourceType) {
      _privateBytes = _loadPrivate();
    }
  }

  Future<Uint8List>? _loadPrivate() =>
      widget.sourceType == ImageSourceType.network &&
              PrivatePhotoService.isPrivateReference(widget.imageUrl)
          ? PrivatePhotoService.load(widget.imageUrl)
          : null;

  @override
  Widget build(BuildContext context) {
    if (_privateBytes != null) {
      return FutureBuilder<Uint8List>(
        future: _privateBytes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _status(context, const Text('Error loading image'));
          }
          if (!snapshot.hasData) {
            return _status(context, const CircularProgressIndicator());
          }
          return _photoView(context, MemoryImage(snapshot.data!));
        },
      );
    }
    ImageProvider imageProvider;
    switch (widget.sourceType) {
      case ImageSourceType.network:
        imageProvider = CachedNetworkImageProvider(
          widget.imageUrl,
          headers: const {
            // HttpHeaders.authorizationHeader:
            //     'Bearer ${supabase.auth.currentSession?.accessToken}'
          },
        );
        break;
      case ImageSourceType.file:
        imageProvider = FileImage(File(widget.imageUrl));
        break;
      case ImageSourceType.asset:
        imageProvider = AssetImage(widget.imageUrl);
        break;
    }
    return _photoView(context, imageProvider);
  }

  Widget _status(BuildContext context, Widget child) => Stack(
    children: [
      Center(child: child),
      if (widget.viewCloseButton)
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
    ],
  );

  Widget _photoView(BuildContext context, ImageProvider imageProvider) {
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
                      event == null ||
                              event.expectedTotalBytes == null ||
                              event.expectedTotalBytes == 0
                          ? null
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                ),
              ),
          imageProvider: imageProvider,
        ),
        if (widget.viewCloseButton)
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
