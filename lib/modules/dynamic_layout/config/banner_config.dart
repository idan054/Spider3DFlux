import 'package:flutter/cupertino.dart';

import '../helper/helper.dart';
import 'header_config.dart';

/// layout : 'bannerImage'
/// design : 'default'
/// fit : 'cover'
/// marginLeft : 5
/// intervalTime : 3
/// items : [{'category':28,'image':'https://user-images.githubusercontent.com/1459805/59846818-12672e80-938b-11e9-8184-5f7bfe66f1a2.png','padding':15},{'padding':15,'image':'https://user-images.githubusercontent.com/1459805/60091575-1f12ca80-976f-11e9-962c-bdccff60d143.png','category':29},{'image':'https://user-images.githubusercontent.com/1459805/60091808-a19b8a00-976f-11e9-9cc7-576ca05c2442.png','padding':15,'product':30}]
/// marginBottom : 5
/// autoPlay : false
/// isSlider : true
/// height : 0.2
/// marginRight : 5
/// marginTop : 5
/// radius : 2

const imageDefault =
    'https://user-images.githubusercontent.com/1459805/59846818-12672e80-938b-11e9-8184-5f7bfe66f1a2.png';

class BannerConfig {
  HeaderConfig? title;

  String? text;
  String? layout;
  String? design;
  String? imageBanner;
  BoxFit? fit;
  int? intervalTime;
  // late final List<BannerItemConfig> items; // original
  List<BannerItemConfig> items = [];

  late final bool autoPlay;
  late final bool isSlider;
  late final bool showNumber;
  late final bool isBlur;
  late final bool showBackground;

  /// bool type
  double? height;
  late final double padding;
  late final double marginLeft;
  late final double marginRight;
  late final double marginTop;
  late final double marginBottom;
  late final double radius;
  late final double upHeight;

  BannerConfig({
    this.layout,
    this.text,
    this.title,
    this.design,
    this.imageBanner,
    this.fit,
    this.intervalTime,
    required this.items,
    required this.marginBottom,
    required this.autoPlay,
    required this.isSlider,
    required this.showNumber,
    required this.isBlur,
    required this.showBackground,
    this.height,
    required this.padding,
    required this.marginLeft,
    required this.marginRight,
    required this.marginTop,
    required this.upHeight,
    required this.radius,
  });

  BannerConfig.fromJson(dynamic json) {
    title = json['title'] != null ? HeaderConfig.fromJson(json['title']) : null;
    layout = json['layout'];
    text = json['text'];
    design = json['design'];
    imageBanner = json['imageBanner'];
    fit = Helper.boxFit(json['fit']);
    intervalTime = json['intervalTime'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(BannerItemConfig.fromJson(v));
      });
    }

    autoPlay = json['autoPlay'] ?? false;
    showBackground = json['showBackground'] ?? false;
    isSlider = json['isSlider'] ?? false;
    showNumber = json['showNumber'] ?? false;
    isBlur = json['isBlur'] ?? false;

    /// double
    height = Helper.formatDouble(json['height']);
    upHeight = Helper.formatDouble(json['upHeight']) ?? 0.0;
    padding = Helper.formatDouble(json['padding']) ?? 0.0;
    radius = Helper.formatDouble(json['radius']) ?? 6.0;

    /// spacing
    marginLeft = Helper.formatDouble(json['marginLeft']) ?? 0.0;
    marginRight = Helper.formatDouble(json['marginRight']) ?? 0.0;
    marginTop = Helper.formatDouble(json['marginTop']) ?? 0.0;
    marginBottom = Helper.formatDouble(json['marginBottom']) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['layout'] = layout;
    map['design'] = design;
    map['fit'] = fit;
    map['marginLeft'] = marginLeft;
    map['intervalTime'] = intervalTime;
    map['items'] = items.map((v) => v.toJson()).toList();
    map['marginBottom'] = marginBottom;
    map['autoPlay'] = autoPlay;
    map['isSlider'] = isSlider;
    map['height'] = height;
    map['marginRight'] = marginRight;
    map['marginTop'] = marginTop;
    map['radius'] = radius;
    map.removeWhere((key, value) => value == null);
    return map;
  }
}

/// category : 28
/// image : 'https://user-images.githubusercontent.com/1459805/59846818-12672e80-938b-11e9-8184-5f7bfe66f1a2.png'
/// padding : 15

class BannerItemConfig {
  dynamic categoryId;
  late String image;
  double? padding;
  double? radius;
  List<dynamic>? data;
  dynamic jsonData;
  String? background;

  BannerItemConfig({
    this.categoryId,
    required this.image,
    this.radius,
    this.padding,
    this.data,
    this.jsonData,
    this.background,
  });

  BannerItemConfig.fromJson(dynamic json) {
    categoryId = json['category'];
    image = json['image'] ?? imageDefault;
    padding = Helper.formatDouble(json['padding']);
    radius = Helper.formatDouble(json['radius']);
    data = json['data'];
    background = json['background'];
    // ignore: prefer_initializing_formals
    jsonData = json;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['category'] = categoryId;
    map['image'] = image;
    map['padding'] = padding;
    map['radius'] = radius;
    map['data'] = data;
    map['jsonData'] = jsonData;
    map['background'] = background;
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
