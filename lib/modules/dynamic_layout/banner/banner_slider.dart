import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fstore/models/app_model.dart';
import 'package:page_indicator/page_indicator.dart';

import '../config/banner_config.dart';
import '../header/header_text.dart';
import '../helper/helper.dart';
import 'banner_items.dart';
import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// The Banner Group type to display the image as multi columns
class BannerSlider extends StatefulWidget {
  final BannerConfig config;
  final Function onTap;

  BannerSlider({required this.config, required this.onTap, Key? key})
      : super(key: key);

  @override
  _StateBannerSlider createState() => _StateBannerSlider();
}

class _StateBannerSlider extends State<BannerSlider> {
  PageController? _controller;
  late bool autoPlay;
  Timer? timer;
  late int intervalTime;

  // region original slider
  // int position = 0;
  //
  // @override
  // void initState() {
  //   autoPlay = widget.config.autoPlay;
  //   _controller = PageController();
  //   intervalTime = widget.config.intervalTime ?? 3;
  //   autoPlayBanner();
  //
  //   super.initState();
  // }
  //
  // void autoPlayBanner() {
  //   List? items = widget.config.items;
  //   timer = Timer.periodic(Duration(seconds: intervalTime), (callback) {
  //     if (widget.config.design != 'default' || !autoPlay) {
  //       timer!.cancel();
  //     } else if (widget.config.design == 'default' && autoPlay) {
  //       if (position >= items.length - 1 && _controller!.hasClients) {
  //         // _controller!.jumpToPage(0);
  //         _controller!.animateToPage(0,
  //                           duration: const Duration(milliseconds: 800),
  //                           curve: Curves.easeInOut);
  //       } else {
  //         if (_controller!.hasClients) {
  //           _controller!.animateToPage(position + 1,
  //               duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  //         }
  //       }
  //     }
  //   });
  // }
  // endregion original slider

  int position = 0; // Global Setup
  List items = []; // Global Setup

  @override
  void initState() {
    /*List? */ items = widget.config.items;
    // position = items.length - 1; // REAL Setup

    autoPlay = widget.config.autoPlay;
    _controller = PageController();
    intervalTime = widget.config.intervalTime ?? 5;
    autoPlayBanner();

    super.initState();
  }

  void autoPlayBanner() {
    // List? items = widget.config.items;
    timer = Timer.periodic(Duration(seconds: intervalTime), (callback) {
      if (widget.config.design != 'default' || !autoPlay) {
        timer!.cancel();
      } else if (widget.config.design == 'default' && autoPlay) {
        // if (position >= items.length - 1 && _controller!.hasClients) {
        if (position <= 0 && _controller!.hasClients) {
          // print("$position, ${items.length}");
          // _controller!.jumpToPage(0);
          // _controller!.animateToPage(2,
          _controller!.animateToPage(items.length - 1,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut);
        } else {
          if (_controller!.hasClients) {
            // print("$position < ${items.length - 1}");
            _controller!.animateToPage(position - 1,
                duration: const Duration(seconds: 1), curve: Curves.easeInOut);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    _controller!.dispose();
    super.dispose();
  }

  Widget getBannerPageView(width) {
    List items = widget.config.items;
    var showNumber = widget.config.showNumber;
    var boxFit = widget.config.fit;

    // if (items.isNotEmpty) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Stack(
        children: <Widget>[
          PageIndicatorContainer(
            align: IndicatorAlign.bottom,
            length: items.length,
            indicatorSpace: 5.0,
            padding: const EdgeInsets.all(10.0),
            indicatorColor: Colors.black12.withOpacity(0),
            indicatorSelectorColor: Colors.black87.withOpacity(0),
            shape: IndicatorShape.roundRectangleShape(
              size: showNumber ? const Size(0.0, 0.0) : const Size(25.0, 2.0),
            ),
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  position = index;
                });
              },
              children: <Widget>[
                for (int i = 0; i < items.length; i++)
                  BannerImageItem(
                    config: items[i],
                    width: width,
                    boxFit: boxFit,
                    padding: widget.config.padding,
                    radius: widget.config.radius,
                    onTap: widget.onTap,
                  ),
              ],
            ),
          ),
          showNumber
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.6)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        child: Text(
                          '${position + 1}/${items.length}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
    // } else {}
    // return Container();
  }

  Widget renderBannerItem({required BannerItemConfig config, double? width}) {
    return BannerImageItem(
      config: config,
      width: width,
      boxFit: widget.config.fit,
      radius: widget.config.radius,
      padding: widget.config.padding,
      onTap: widget.onTap,
    );
  }

  Widget renderBanner(width) {
    List? items = widget.config.items;

    switch (widget.config.design) {
      case 'swiper':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return renderBannerItem(config: items[index], width: width);
          },
          itemCount: items.length,
          viewportFraction: 0.85,
          scale: 0.9,
          duration: intervalTime * 1000,
        );
      case 'tinder':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return renderBannerItem(config: items[index], width: width);
          },
          itemCount: items.length,
          itemWidth: width,
          itemHeight: width * 1.2,
          layout: SwiperLayout.TINDER,
          duration: intervalTime * 1000,
        );
      case 'stack':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return renderBannerItem(config: items[index], width: width);
          },
          itemCount: items.length,
          itemWidth: width - 40,
          layout: SwiperLayout.STACK,
          duration: intervalTime * 1000,
        );
      case 'custom':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return renderBannerItem(config: items[index], width: width);
          },
          itemCount: items.length,
          itemWidth: width - 40,
          itemHeight: width + 100,
          duration: intervalTime * 1000,
          layout: SwiperLayout.CUSTOM,
          customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
              .addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate(
            [
              const Offset(-370.0, -40.0),
              const Offset(0.0, 0.0),
              const Offset(370.0, -40.0)
            ],
          ),
        );
      default:
        return getBannerPageView(width);
    }
  }

  double? bannerPercent(width) {
    final screenSize = MediaQuery.of(context).size;
    return Helper.formatDouble(
        widget.config.height ?? 0.5 / (screenSize.height / width));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var isBlur = widget.config.isBlur;

    List? items = widget.config.items;
    var bannerExtraHeight =
        screenSize.height * (widget.config.title != null ? 0.12 : 0.0);
    var upHeight = Helper.formatDouble(widget.config.upHeight);

    //Set autoplay for default template
    autoPlay = widget.config.autoPlay;
    if (widget.config.design == 'default' && timer != null) {
      if (!autoPlay) {
        if (timer!.isActive) {
          timer!.cancel();
        }
      } else {
        if (!timer!.isActive) {
          Future.delayed(Duration(seconds: intervalTime), () => autoPlayBanner);
        }
      }
    }
    if (items.isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraint) {
          var _bannerPercent = bannerPercent(constraint.maxWidth)!;
          var height = screenSize.height * _bannerPercent +
              bannerExtraHeight +
              upHeight!;
          BannerItemConfig item = items[position];
          return FractionallySizedBox(
            widthFactor: 1.0,
            child: Container(
              margin: EdgeInsets.only(
                left: widget.config.marginLeft,
                right: widget.config.marginRight,
                top: widget.config.marginTop,
                bottom: widget.config.marginBottom,
              ),
              child: Stack(
                children: <Widget>[
                  if (widget.config.showBackground)
                    Container(
                      height: height,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.elliptical(100, 6),
                          ),
                          child: Stack(children: <Widget>[
                            isBlur
                                ? Transform.scale(
                                    scale: 3,
                                    child: Image.network(
                                      item.background ?? item.image,
                                      fit: BoxFit.fill,
                                      width: screenSize.width + upHeight,
                                    ),
                                  )
                                : Image.network(
                                    item.background ?? item.image,
                                    fit: BoxFit.fill,
                                    width: constraint.maxWidth,
                                    height: screenSize.height * _bannerPercent +
                                        bannerExtraHeight +
                                        upHeight,
                                  ),
                            ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: isBlur ? 12 : 0,
                                    sigmaY: isBlur ? 12 : 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(isBlur ? 0.6 : 0.0),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      if (widget.config.title != null)
                        HeaderText(config: widget.config.title!),
                      Container(
                        height: screenSize.height * _bannerPercent,
                        child: renderBanner(constraint.maxWidth),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {}
    return Container();
  }
}
