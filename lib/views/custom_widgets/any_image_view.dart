import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/services/private_photo_service.dart';

class AnyImageView extends StatelessWidget {
  const AnyImageView({
    super.key,
    this.ontap,
    this.fit = BoxFit.cover,
    this.errorFit = BoxFit.contain,
    this.fileType = SourceType.network,
    this.containerBackgroundColor,
    this.borderRadius,
    this.border,
    this.useCache = true,
    this.isCircle = false,
    this.imageColor,
    this.padding,
    this.errorWidget,
    this.height,
    this.width,
    this.errorImage = AppImages.kDefaultTripImage,
    required this.url,
  });
  final String url;
  final SourceType fileType;
  final String errorImage;
  final Color? containerBackgroundColor;
  final Widget? errorWidget;
  final EdgeInsetsGeometry? padding;
  final BoxFit fit;
  final BoxFit errorFit;
  final BoxBorder? border;
  final Color? imageColor;
  final double? height;
  final BorderRadius? borderRadius;
  final double? width;
  final bool useCache;
  final bool isCircle;
  final Function()? ontap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: ontap, child: getContainer());
  }

  Container getContainer() {
    return Container(
      padding:
          border != null
              ? const EdgeInsets.all(1)
              : errorImage == 'assets/icons/ic_user.png'
              ? const EdgeInsets.all(3)
              : padding,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: containerBackgroundColor,
        border: border,
        borderRadius: isCircle ? null : borderRadius,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child:
          !isCircle
              ? ClipRRect(
                borderRadius: borderRadius ?? BorderRadius.circular(0),
                child: getImage(),
              )
              : ClipOval(child: getImage()),
    );
  }

  Widget getImage() {
    // Get.log('user token: ${supabase.auth.currentSession?.accessToken}');
    switch (fileType) {
      case SourceType.network:
        if (PrivatePhotoService.isPrivateReference(url)) {
          return _PrivatePhotoImage(
            url: url,
            fit: fit,
            height: height,
            width: width,
            color: imageColor,
            loading: (context) => laodingShimmer(context),
            error: getErrorWidget,
          );
        }
        return useCache
            ? CachedNetworkImage(
              filterQuality: FilterQuality.high,
              imageUrl: url,
              httpHeaders: const {
                // HttpHeaders.authorizationHeader:
                //     'Bearer ${supabase.auth.currentSession?.accessToken}'
              },
              fit: fit,
              height: height,
              color: imageColor,
              width: width,
              progressIndicatorBuilder:
                  (context, url, progress) => laodingShimmer(context),
              errorWidget:
                  (context, url, error) =>
                      padding == null
                          ? getErrorWidget()
                          : Padding(padding: padding!, child: getErrorWidget()),
            )
            : Image.network(
              url,
              fit: fit,
              headers: const {
                // HttpHeaders.authorizationHeader:
                //     'Bearer ${supabase.auth.currentSession?.accessToken}'
              },
              height: height,
              color: imageColor,
              width: width,
              frameBuilder:
                  (context, child, frame, wasSynchronouslyLoaded) =>
                      frame == null ? laodingShimmer(context) : child,
              errorBuilder: (context, error, stackTrace) => getErrorWidget(),
            );
      case SourceType.file:
        return Image.file(
          File(url),
          fit: fit,
          frameBuilder:
              (context, child, frame, wasSynchronouslyLoaded) =>
                  frame == null ? laodingShimmer(context) : child,
          height: height,
          width: width,
          color: imageColor,
          errorBuilder: (context, error, stackTrace) => getErrorWidget(),
        );
      case SourceType.asset:
        return Image.asset(
          url,
          fit: fit,
          frameBuilder:
              (context, child, frame, wasSynchronouslyLoaded) =>
                  frame == null ? laodingShimmer(context) : child,
          height: height,
          color: imageColor,
          width: width,
          errorBuilder: (context, error, stackTrace) => getErrorWidget(),
        );
    }
  }

  Widget laodingShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Theme.of(context).primaryColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  Widget getErrorWidget() {
    return errorWidget ??
        Image.asset(
          errorImage,
          color: imageColor,
          height: height,
          width: width,
          fit: errorFit,
        );
  }
}

class _PrivatePhotoImage extends StatefulWidget {
  const _PrivatePhotoImage({
    required this.url,
    required this.fit,
    required this.height,
    required this.width,
    required this.color,
    required this.loading,
    required this.error,
  });

  final String url;
  final BoxFit fit;
  final double? height;
  final double? width;
  final Color? color;
  final Widget Function(BuildContext) loading;
  final Widget Function() error;

  @override
  State<_PrivatePhotoImage> createState() => _PrivatePhotoImageState();
}

class _PrivatePhotoImageState extends State<_PrivatePhotoImage> {
  late Future<Uint8List> bytes;

  @override
  void initState() {
    super.initState();
    bytes = PrivatePhotoService.load(widget.url);
  }

  @override
  void didUpdateWidget(covariant _PrivatePhotoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      bytes = PrivatePhotoService.load(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: bytes,
    builder: (context, snapshot) {
      if (snapshot.hasError) return widget.error();
      if (!snapshot.hasData) return widget.loading(context);
      return Image.memory(
        snapshot.data!,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        color: widget.color,
        errorBuilder: (context, error, stackTrace) => widget.error(),
      );
    },
  );
}

enum SourceType { network, file, asset }
