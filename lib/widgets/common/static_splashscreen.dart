import 'package:flutter/material.dart';

import '../../screens/base_screen.dart';

class StaticSplashScreen extends StatefulWidget {
  final String? imagePath;
  final Function? onNextScreen;
  final int duration;
  @override
  final Key? key;

  StaticSplashScreen({
    this.imagePath,
    this.key,
    this.onNextScreen,
    this.duration = 2500,
  });

  @override
  _StaticSplashScreenState createState() => _StaticSplashScreenState();
}

class _StaticSplashScreenState extends BaseScreen<StaticSplashScreen> {
  @override
  void afterFirstLayout(BuildContext context) {
    Future.delayed(Duration(milliseconds: widget.duration), () {
      widget.onNextScreen!();
//      Navigator.of(context).pushReplacement(
//          MaterialPageRoute(builder: (context) => widget.onNextScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset(
          // widget.imagePath!,
          'assets/images/splashscreen.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
