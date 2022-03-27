import 'dart:async';
import 'dart:convert';
import 'dart:io' as file;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspireui/inspireui.dart' show Skeleton, kImageProxy;
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../services/index.dart' show Config;
import '../config.dart' show kAdvanceConfig, serverConfig;
import '../constants.dart' show kDefaultImage, kEmptyColor, kImageProxy, kIsWeb;
import 'dart:math' as math;

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, ProductVariation, RecentModel;
import '../../routes/flux_navigate.dart';
import '../../services/service_config.dart';

enum kSize { small, medium, large } // Lol enum just a class that let u made values. no more.

BoxDecoration myShadowDecoration() {
  return BoxDecoration(
    boxShadow: [
      if (kProductCard['boxShadow'] != null)
        const BoxShadow(
            color: Colors.black12,
            offset: Offset(
              0.5,
              0.5,
            ),
            blurRadius: 4),
    ],
  );
}

class ImageTools {
  static String prestashopImage(String url, [kSize? size = kSize.medium]) {
    if (url.contains('?')) {
      switch (size) {
        case kSize.large:
          return url.replaceFirst('?', '/large_default?');
        case kSize.small:
          return url.replaceFirst('?', '/small_default?');
        default: // kSize.medium
          return url.replaceFirst('?', '/medium_default?');
      }
    }
    switch (size) {
      case kSize.large:
        return '$url/large_default';
      case kSize.small:
        return '$url/small_default';
      default: // kSize.medium
        return '$url/medium_default';
    }
  }

  static String? formatImage(String? url, [kSize? size = kSize.medium]) {
    if (serverConfig['type'] == 'presta') {
      return prestashopImage(url!, size);
    }

    if (Config().isCacheImage ?? kAdvanceConfig['kIsResizeImage']) {
      var pathWithoutExt = p.withoutExtension(url!);
      var ext = p.extension(url);
      String? imageURL = url;

      // if (ext == '.jpeg') {
      if (ext == '.jpeg' || ext == '.jpg' || ext == '.png') {
        imageURL = url;
      } else {
        switch (size) {
          case kSize.large:
            imageURL = '$pathWithoutExt-large$ext';
            break;
          case kSize.small:
            imageURL = '$pathWithoutExt-small$ext';
            break;
          default: // kSize.medium:e
            imageURL = '$pathWithoutExt-medium$ext';
            break;
        }
      }

      // printLog('[🏞Image Caching] $imageURL');
      return imageURL;
    } else {
      return url;
    }
  }

  static NetworkImage networkImage(String? url, [kSize size = kSize.medium]) {
    return NetworkImage(formatImage(url, size) ?? kDefaultImage);
  }

  /// Smart image function to load image cache and check empty URL to return empty box
  /// Only apply for the product image resize with (small, medium, large)
  static Widget image({
    String? url,
    kSize? size,
    double? width,
    double? height,
    BoxFit? fit,
    String? tag,
    double offset = 0.0,
    bool isResize = false,
    bool? isVideo = false,
    bool hidePlaceHolder = false,
    bool forceWhiteBackground = false,
  }) {
    if (height == null && width == null) {
      // width = 200;
      width = 250;
    }
    // var ratioImage = kAdvanceConfig['RatioProductImage'] ?? 1.2;
    var ratioImage = 0.3;


    if (url?.isEmpty ?? true) {
      // print("image_tools: url $url use url?.isEmpty ?? true");

      return FutureBuilder<bool>(
        future: Future.delayed(const Duration(seconds: 0), () => false),
        initialData: true,
        builder: (context, snapshot) {
          final showSkeleton = snapshot.data!;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: showSkeleton
                ? Container(
                    decoration: myShadowDecoration(),
                    child: Skeleton(
                      cornerRadius: 5,
                      width: width!,
                      height: height ?? width * ratioImage,
                      // height: height ?? width * 0.3,
                    ),
                  )
                : SizedBox(
                    width: width,
                    height: height ?? width! * ratioImage,
                    // height: height ?? width! * 0.3,
                    child: Container(
                      // decoration: myShadowDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                            color: Colors.black.withOpacity(0.07),
                            child: const Center(child: Icon(Icons.image))),
                      ),
                    ),
                  ),
          );
        },
      );
    }

    if (isVideo!) {
      return Stack(
        children: <Widget>[
          Container(
            decoration: myShadowDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(color: Colors.black12.withOpacity(1)),
                child: ExtendedImage.network(
                  isResize ? formatImage(url, size)! : url!,
                  width: width,
                  // height: height ?? width! * ratioImage,
                  height: height ?? width! * 0.3,
                  fit: BoxFit.cover,
                  cache: true,
                  enableLoadState: false,
                  alignment: Alignment(
                      (offset >= -1 && offset <= 1)
                          ? offset
                          : (offset > 0)
                              ? 1.0
                              : -1.0,
                      0.0),
                ),
              ),
            ),
          ),
          Visibility(
            visible: false,
            child: Positioned.fill(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.black26.withOpacity(0.5),
                // size: width == null ? 20 : width / 1.7,
                size: 50,
              ),
            ),
          ),
        ],
      );
    }

    if (kIsWeb) {
      /// temporary fix on CavansKit https://github.com/flutter/flutter/issues/49725
      var imageURL = isResize ? formatImage(url, size) : url;

      // print("image_tools: imageURL $imageURL use kIsWeb");

      return ConstrainedBox(
        // constraints: BoxConstraints(maxHeight: width! * ratioImage),
        constraints: BoxConstraints(maxHeight: width! * ratioImage),
        child: FadeInImage.memoryNetwork(
          image: '$kImageProxy$imageURL',
          fit: fit,
          width: width,
          height: height,
          placeholder: kTransparentImage,
        ),
      );
    }

    var imageURL = isResize ? formatImage(url, size) : url;

    final my_image_based_cache_pack = CachedNetworkImage(
      width: width,
      height: height,
      fit: fit,
      alignment: Alignment(
        (offset >= -1 && offset <= 1)
            ? offset
            : (offset > 0)
                ? 1.0
                : -1.0,
        0.0,
      ),
      imageUrl: '$kImageProxy$imageURL',
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );

    final image = ExtendedImage.network(
      // final original_image = ExtendedImage.network(
      // isResize ? formatImage(url, size)! : url!,
      url!,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      enableLoadState: false,
      alignment: Alignment(
        (offset >= -1 && offset <= 1)
            ? offset
            : (offset > 0)
                ? 1.0
                : -1.0,
        0.0,
      ),
      loadStateChanged: (ExtendedImageState state) {
        Widget? widget;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            widget = hidePlaceHolder
                ? const SizedBox()
                : Skeleton(
                    width: width ?? 100,
                    height: width ?? 100 * ratioImage * 2,
                  );
            break;
          case LoadState.completed:
            widget = ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: width,
              height: height,
              fit: fit,
            );
            break;
          case LoadState.failed:
            widget = Container(
              width: width,
              height: height ?? width!, //\\ * ratioImage,
              color: const Color(kEmptyColor),
            );
            break;
        }
        // print("image_tools: $url use image = ExtendedImage.network");
        return widget;
      },
    );

    if (forceWhiteBackground && url!.toLowerCase().endsWith('.png') ||
        forceWhiteBackground && url!.toLowerCase().endsWith('.jpeg') ||
        forceWhiteBackground && url!.toLowerCase().endsWith('.jpg')) {
      // print("image_tools: $url use url!.toLowerCase()");

      return Container(
        color: Colors.white,
        child: image,
      );
    }

    return image;
  }

  /// cache avatar for the chat
  static CachedNetworkImage getCachedAvatar(String avatarUrl) {
    return CachedNetworkImage(
      imageUrl: avatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  static BoxFit boxFit(String? fit) {
    switch (fit) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'scaleDown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  static Future<String> compressAndConvertImagesForUploading(
      List<dynamic> images) async {
    var base64 = StringBuffer();
    for (final image in images) {
      base64
        ..write(await compressImage(image))
        ..write(',');
    }
    return base64.toString();
  }

  static Future<file.File> _writeToFile(ByteData data) async {
    final buffer = data.buffer;
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    var filePath = tempPath + '/file_01.jpeg';
    var f = file.File(filePath);
    await f.writeAsBytes(buffer.asUint8List());
    return f;
    // return File(filePath).writeAsBytes(
    //     buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<String> compressImage(dynamic image) async {
    var base64 = '';
    //const quality = 60;

    /// Disable cause the build issue on Flutter 2.2
    /// https://github.com/OpenFlutter/flutter_image_compress/issues/180

    if (image is Asset) {
      final byteData = await image.getByteData(quality: 100);
      final tmpFile = await _writeToFile(byteData);

      // final result = await FlutterImageCompress.compressWithList(
      //   bytes,
      //   minHeight: 800,
      //   minWidth: 800,
      //   quality: quality,
      //   format: CompressFormat.jpeg,
      // );
      // base64 += base64Encode(result);
      final compressedFile = await FlutterNativeImage.compressImage(
        tmpFile.path,
      );
      final bytes = compressedFile.readAsBytesSync();
      base64 += base64Encode(bytes);
    }
    if (image is PickedFile) {
      final compressedFile = await FlutterNativeImage.compressImage(
        image.path,
      );
      final bytes = compressedFile.readAsBytesSync();
      base64 += base64Encode(bytes);
      //   /// disable as not support File on web
      //   final result = await (FlutterImageCompress.compressWithFile(
      //     File(image.path).absolute.path,
      //     minWidth: 800,
      //     minHeight: 800,
      //     quality: quality,
      //     format: CompressFormat.jpeg,
      //   ) as Future<Uint8List>);
      //   base64 += base64Encode(result);
    }
    if (image is String) {
      if (image.contains('http')) {
        base64 += image;
      }
    }
    return base64;
  }
}
