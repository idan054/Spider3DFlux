import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspireui/widgets/onboarding/intro_slider/intro_slider_wrapper.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart';
import '../../common/config.dart' as config;
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel;
import 'change_language_mixin.dart';

class OnBoardScreen extends StatefulWidget {
  OnBoardScreen();

  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> with ChangeLanguage {
  final isRequiredLogin = config.kLoginSetting['IsRequiredLogin'];
  int page = 0;

  List<SlideWrapper> getSlides(Map appConfig) {
    final slides = <SlideWrapper>[];
    final data = appConfig['OnBoarding'] != null
        ? appConfig['OnBoarding']['data']
        : config.onBoardingData;

    Widget loginWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Image.asset(
          kOrderCompleted,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: GestureDetector(
            onTap: () async {
              var prefs = await SharedPreferences.getInstance();
              await prefs.setBool('seen', true);
              await Navigator.pushReplacementNamed(context, RouteList.login);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).signIn,
                  style: const TextStyle(
                    color: kColorSpiderRed,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     GestureDetector(
          //       onTap: () async {
          //         var prefs = await SharedPreferences.getInstance();
          //         await prefs.setBool('seen', true);
          //         await Navigator.pushReplacementNamed(
          //             context, RouteList.login);
          //       },
          //       child: Text(
          //         S.of(context).signIn,
          //         style: const TextStyle(
          //           color: kColorSpiderRed,
          //           fontSize: 20.0,
          //         ),
          //       ),
          //     ),
          //     const Text(
          //       '    |    ',
          //       style: TextStyle(color: kColorSpiderRed, fontSize: 20.0),
          //     ),
          //     GestureDetector(
          //       onTap: () async {
          //         var prefs = await SharedPreferences.getInstance();
          //         await prefs.setBool('seen', true);
          //         await Navigator.pushReplacementNamed(
          //             context, RouteList.register);
          //       },
          //       child: Text(
          //         S.of(context).signUp,
          //         style: const TextStyle(
          //           color: kColorSpiderRed,
          //           fontSize: 20.0,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ],
    );

    for (var i = 0; i < data.length; i++) {
      var slide = SlideWrapper(
        title: '',
        //data[i]['title'],
        description: data[i]['desc'],
        maxLineTitle: 2,
        marginTitle: const EdgeInsets.only(
            // top: 125.0,
            // top: 50.0,
            // bottom: 50.0,
            ),
        maxLineTextDescription: 2,
        styleTitle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: kGrey900,
        ),
        backgroundColor: Colors.white,
        marginDescription: const EdgeInsets.fromLTRB(20.0, 75.0, 20.0, 0),
        styleDescription: const TextStyle(
          fontSize: 15.0,
          color: kGrey600,
        ),
        foregroundImageFit: BoxFit.fitWidth,
      );

      if (i == 1) {
        slide.centerWidget = loginWidget;
        // Navigator.pushReplacementNamed(context, RouteList.login)
      } else {
        slide.centerWidget = Container();
        // slide.pathImage = data[i]['image'];
      }
      slides.add(slide);
    }
    return slides;
  }

  static const textStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  List<Widget> getPages(List data) {
    return [
      for (int i = 0; i < data.length; i++)
        Container(
          color: HexColor(data[i]['background']),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                data[i]['image'],
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Column(
                children: <Widget>[
                  Text(
                    data[i]['title'],
                    style: textStyle.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data[i]['desc'],
                    style: textStyle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        )
    ];
  }

  Widget _buildDot(int index) {
    var selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - (page - index).abs(),
      ),
    );
    var zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return Container(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  void pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }

  void onTapDone() async {
    if (isRequiredLogin) {
      return;
    }
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);
    await Navigator.pushReplacementNamed(context, RouteList.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final _appConfig = Provider.of<AppModel>(context).appConfig?.jsonData;
    String? boardType = _appConfig['OnBoarding'] != null
        ? _appConfig['OnBoarding']['layout']
        : null;
    switch (boardType) {
      case 'liquid':
        return MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                LiquidSwipe(
                  fullTransitionValue: 200,
                  enableLoop: true,
                  positionSlideIcon: 0.5,
                  onPageChangeCallback: pageChangeCallback,
                  waveType: WaveType.liquidReveal,
                  pages: getPages(_appConfig['OnBoarding']['data']),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(5, _buildDot),
                      ),
                    ],
                  ),
                ),
                iconLanguage(),
              ],
            ),
          ),
        );
      default:
        return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                // TextField(),
                Image.asset(
                  // data[i]['image'],
                  "assets/images/welcome_coupon.png",
                  fit: BoxFit.cover,
                ),
                // const SizedBox(height: 35),
                const Text(
                  'משלוח חינם! \nמתנת הצטרפות מאיתנו',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: kGrey900,
                  ),
                ),
                // Desc Text:
                const Visibility(
                  visible: true,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                    child: Text(
                      // 'משלוח ראשון חינם ומבצעים בלעדיים נוספים לחברי האפליקציה',
                      '\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // Copy Coupon
                    var data = const ClipboardData(text: 'SpiderGift');
                    await Clipboard.setData(data);
                    const snackBar = SnackBar(
                        content: Text('מעולה! הקופון SpiderGift הועתק.'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    color: Colors.grey[100],
                    // child: const SelectableText(
                    child: Text(
                      'SpiderGift#',
                      // style: TextStyle(color: kColorSpiderRed, fontSize: 20.0),
                      style: TextStyle(color: Colors.grey[700], fontSize: 20.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          kColorSpiderRed.withOpacity(0.05)),
                      foregroundColor:
                          MaterialStateProperty.all(kColorSpiderRed),
                      // MaterialStateProperty.all(Colors.grey[700]),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      // backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
                      elevation: MaterialStateProperty.all(2)),
                  onPressed: () async {
                    // Copy Coupon
                    var data = const ClipboardData(text: 'SpiderGift');
                    await Clipboard.setData(data);
                    const snackBar = SnackBar(
                        content: Text('מעולה! הקופון SpiderGift הועתק.'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    // Go To login Screen
                    var prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seen', true);
                    await Navigator.pushReplacementNamed(
                        context, RouteList.login);
                  },
                  child: const Text(
                    'התחבר והעתק קופון',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      // color: kGrey900,
                    ),
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible: Platform.isIOS,
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          kColorSpiderRed.withOpacity(0.05)),
                      foregroundColor: MaterialStateProperty.all(kColorSpiderRed),
                      // MaterialStateProperty.all(Colors.grey[700]),
                      // backgroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.grey[100]),
                      // backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
                      // elevation: MaterialStateProperty.all(2)
                    ),
                    onPressed: () async {
                      var prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('seen', true);
                      void showLoading() {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Center(
                                child: Container(
                              padding: const EdgeInsets.all(50.0),
                              child: kLoadingWidget(context),
                            ));
                          },
                        );
                      }

                      // showLoading();
                      await Navigator.pushReplacementNamed(
                          context, RouteList.dashboard);
                    },
                    child: Text(
                      // 'דלג על ההתחברות',
                      'דלג וותר על הקופון',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ));
      // return Scaffold(
      // // backgroundColor: Colors.white,
      // body: Consumer<AppModel>(builder: (context, _, __) {
      //   return Container(
      //     key: UniqueKey(),
      //     child: IntroSliderWrapper(
      //       slides: getSlides(_appConfig),
      //       styleSkipBtn: const TextStyle(color: kGrey900),
      //       styleDoneBtn: const TextStyle(color: kGrey900),
      //       namePrevBtn: S.of(context).prev,
      //   // isShowSkipBtn: false,
      // nameSkipBtn: '', // S.of(context).skip,
      // nameNextBtn: '', // S.of(context).next,
      // nameDoneBtn: isRequiredLogin ? '' : S.of(context).done,
      // isShowDoneBtn: !isRequiredLogin,
      // onDonePress: onTapDone,
      // ),
      // );
      // }),
      // );
    }
  }
}
