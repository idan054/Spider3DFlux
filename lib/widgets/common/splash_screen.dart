import 'package:flutter/material.dart';

import '../../common/constants.dart';
import 'animated_splash.dart';
import 'flare_splash_screen.dart';
import 'rive_splashscreen.dart';
import 'static_splashscreen.dart';

class SplashScreenIndex extends StatelessWidget {
  final Function actionDone;
  final String splashScreenType;
  final String imageUrl;

  const SplashScreenIndex({
    Key? key,
    required this.actionDone,
    required this.imageUrl,
    this.splashScreenType = SplashScreenTypeConstants.static,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print("---------------");
    // print(splashScreenType);
    // print("---------------");
    switch (splashScreenType) {
      case SplashScreenTypeConstants.rive:
        const animationName = kAnimationName;
        return RiveSplashScreen(
          onSuccess: actionDone,
          asset: imageUrl,
          animationName: animationName,
        );
      case SplashScreenTypeConstants.flare:
        return SplashScreen.navigate(
          name: imageUrl,
          startAnimation: kAnimationName,
          backgroundColor: Colors.white,
          next: actionDone,
          until: () => Future.delayed(const Duration(seconds: 2)),
        );
      case SplashScreenTypeConstants.fadeIn:
      case SplashScreenTypeConstants.topDown:
      case SplashScreenTypeConstants.zoomIn:
      case SplashScreenTypeConstants.zoomOut:
        return AnimatedSplash(
          imagePath: imageUrl,
          animationEffect: splashScreenType,
          next: actionDone,
          secondsTimeDelay: 3,
        );
      case SplashScreenTypeConstants.static:
      default:
        return StaticSplashScreen(
          imagePath: imageUrl,
          onNextScreen: actionDone,
        );
    }
  }
}
