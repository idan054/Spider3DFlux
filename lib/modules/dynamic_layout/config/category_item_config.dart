
import 'package:flutter/cupertino.dart';
import 'package:inspireui/utils/colors.dart';

/// originalColor : false
/// title : false
/// keepDefaultTitle : false
/// colors : ['#3CC2BF','#3CC2BF']
/// image : 'https://user-images.githubusercontent.com/1459805/62820029-2e679f00-bb88-11e9-80de-fdf115cfd942.png'
/// tag : '58'
/// category : '58'

class CategoryItemConfig {
  bool? originalColor;
  String? title;
  String? description;
  String? name;
  bool keepDefaultTitle = false;
  List<HexColor>? colors;
  String? image;
  String? tag;
  bool? showText = false;
  dynamic category;
  HexColor? backgroundColor;
  List<dynamic>? data;
  dynamic jsonData;

  CategoryItemConfig(
      {this.originalColor,
      this.title,
      this.name,
      this.keepDefaultTitle = false,
      this.showText = false,
      this.colors,
      this.image,
      this.tag,
      this.data,
      this.backgroundColor,
      this.jsonData,
      this.category});

  CategoryItemConfig.fromJson(dynamic json) {
    originalColor = json['originalColor'] ?? false;
    title = json['title'] ?? json['description'];
    name = json['name'];
    showText = json['showText'];
    keepDefaultTitle = json['keepDefaultTitle'] ?? false;
    colors = HexColor.fromListJson(json['colors'] ?? [0xFFFFFFF.toString()]);
    image = json['image'];
    tag = json['tag'];
    category = json['category'] ?? '';
    data = json['data'];

    backgroundColor = HexColor.fromJson(json['backgroundColor']);
    // ignore: prefer_initializing_formals
    jsonData = json;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['originalColor'] = originalColor;
    map['title'] = title;
    map['keepDefaultTitle'] = keepDefaultTitle;
    map['colors'] = colors;
    map['image'] = image;
    map['tag'] = tag;
    map['category'] = category;
    return map;
  }

  List<Color> get alphaColors => colors!.map((e) => e.withAlpha(30)).toList();

  Color? get getBackgroundColor {
    /// ignore the white color as consider blank setting
    if (backgroundColor.toString() == 'Color(0xffffffff)' ||
        backgroundColor == null) {
      return colors!.length == 1 ? colors!.first.withAlpha(30) : null;
    }

    return backgroundColor!.withAlpha(30);
  }

  LinearGradient? get getGradientColor =>
      getBackgroundColor == null ? LinearGradient(colors: alphaColors) : null;
}
