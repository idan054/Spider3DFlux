import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/banner_config.dart';

/// The Banner type to display the image
class BannerImageItem extends StatelessWidget {
  @override
  final Key? key;
  final BannerItemConfig config;
  final double? width;
  final double padding;
  final BoxFit? boxFit;
  final double radius;
  final double? height;
  final Function onTap;

  const BannerImageItem({
    this.key,
    required this.config,
    required this.padding,
    this.width,
    this.boxFit,
    required this.radius,
    this.height,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _padding = config.padding ?? padding;
    var _radius = config.radius ?? radius;

    final screenSize = MediaQuery.of(context).size;
    final screenWidth =
        screenSize.width / (2 / (screenSize.height / screenSize.width));
    final itemWidth = width ?? screenWidth;

    return GestureDetector(
      // onTap: () => print(config.image.toString()),
      // onTap: () {//   config.jsonData;// },
      onTap: () {
        onTap(config.jsonData);
        print(onTap(config.jsonData));
      },
      child: Container(
        width: itemWidth,
        constraints: const BoxConstraints(minHeight: 10.0),
        child: Padding(
          // padding: EdgeInsets.only(left: _padding, right: _padding),
          padding: const EdgeInsets.only(left: 5, right: 5),
          // padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            // This condition JUST allow to use link or file on the config.
            child: config.image.toString().contains('http')
                ? ImageTools.image(
                    // fit: boxFit ?? BoxFit.fitWidth,
                    fit: BoxFit.fill,
                    url: config.image,
                  )
                : Image.asset(
                    config.image,
              fit: boxFit ?? BoxFit.fitWidth,
              // fit: BoxFit.fill,
                  ),
          ),
        ),
      ),
    );
  }
}
