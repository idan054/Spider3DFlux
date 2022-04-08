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

import 'common/config.dart';
import 'common/constants.dart';
import 'models/index.dart'
    show
        AppModel,
        CategoryModel,
        FilterAttributeModel,
        FilterTagModel,
        TagModel;
import 'models/listing/listing_location_model.dart';
import 'models/notification_model.dart';
import 'modules/dynamic_layout/config/app_config.dart';
import 'screens/base_screen.dart';
import 'screens/blog/models/list_blog_model.dart';
import 'services/dependency_injection.dart';
import 'services/index.dart';
import 'widgets/common/splash_screen.dart';

class AppInit extends StatefulWidget {
  const AppInit();

  @override
  _AppInitState createState() => _AppInitState();
}

class _AppInitState extends BaseScreen<AppInit> {
  bool isFirstSeen = false;
  bool isLoggedIn = false;
  bool hasLoadedData = false;
  bool hasLoadedSplash = false;

  late AppConfig? appConfig;

  /// check if the screen is already seen At the first time
  bool checkFirstSeen() {
    /// Ignore if OnBoardOnlyShowFirstTime is set to true.
    if (kAdvanceConfig['OnBoardOnlyShowFirstTime'] == false) {
      return false;
    }

    final _seen =
        injector<SharedPreferences>().getBool(LocalStorageKey.seen) ?? false;
    return _seen;
  }

  /// Check if the App is Login
  bool checkLogin() {
    final hasLogin =
        injector<SharedPreferences>().getBool(LocalStorageKey.loggedIn);
    return hasLogin ?? false;
  }

  Future<void> loadInitData() async {
    try {
      printLog('[AppState] Init Data 💫');
      isFirstSeen = checkFirstSeen();
      isLoggedIn = checkLogin();

      /// set the server config at first loading
      /// Load App model config
      Services().setAppConfig(serverConfig);
      appConfig =
          await Provider.of<AppModel>(context, listen: false)
              .loadAppConfig();
      print('appConfig ${appConfig?.toJson()}');

      Future.delayed(Duration.zero, () {
        /// request app tracking to support io 14.5
        if (isIos) {
          requestAppTrackingTransparency();
        }

        /// Load more Category/Blog/Attribute Model beforehand
        final lang = Provider.of<AppModel>(context, listen: false).langCode;

        /// Request Categories
        Provider.of<CategoryModel>(context, listen: false).getCategories(
          lang: lang,
          sortingList: Provider.of<AppModel>(context, listen: false).categories,
          categoryLayout:
              Provider.of<AppModel>(context, listen: false).categoryLayout,
        );
        printLog('[AppState] Init AppLoad Done loadInitData() 💫');
        hasLoadedData = true;
        if (hasLoadedSplash) {
          // Navigator.of(context).pushReplacementNamed(RouteList.loginSMS);
          goToNextScreen();
        }
      });

      /// Request more Async data which is not use on home screen
      Future.delayed(Duration.zero, () {
        Provider.of<TagModel>(context, listen: false).getTags();

        Provider.of<ListBlogModel>(context, listen: false).getBlogs();

        Provider.of<FilterTagModel>(context, listen: false).getFilterTags();

        Provider.of<FilterAttributeModel>(context, listen: false)
            .getFilterAttributes();

        Provider.of<AppModel>(context, listen: false).loadCurrency();

        context.read<NotificationModel>().loadData();

        if (Config().isListingType) {
          Provider.of<ListingLocationModel>(context, listen: false)
              .getLocations();
        }

        /// Facebook Ads init
        final advertisement =
            Provider.of<AppModel>(context, listen: false).advertisement;
        if (advertisement.enable && !kIsWeb) {
          debugPrint(
              '[AppState] Init Google Mobile Ads and Facebook Audience Network');
          unawaited(FacebookAudienceNetwork.init(
              testingId: advertisement.facebookTestingId));
          unawaited(MobileAds.instance
              .initialize()
              .then((InitializationStatus status) {
            printLog('Initialization done: ${status.adapterStatuses}');
            MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
              tagForChildDirectedTreatment:
                  TagForChildDirectedTreatment.unspecified,
              testDeviceIds: advertisement.googleTestingId,
            ));
          }));
        }
      });

      printLog('[AppState] InitData Finish');
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  void goToNextScreen() {
    if (!isFirstSeen && !kIsWeb && appConfig != null) {
      // Hide For Testing
      if (onBoardingData.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(RouteList.onBoarding);
        return;
      }
    }

    if (kLoginSetting['IsRequiredLogin'] && !isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(RouteList.login);
      return;
    }

    Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
  }

  void checkToShowNextScreen() {
    /// If the config was load complete then navigate to Dashboard
    printLog('[AppState] Init AppLoad Done checkToShowNextScreen()💫');
    hasLoadedSplash = true;
    if (hasLoadedData) {
      // Navigator.of(context).pushReplacementNamed(RouteList.blog);
      goToNextScreen();
      return;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> requestAppTrackingTransparency() async {
    try {
      await AppTrackingTransparency.requestTrackingAuthorization();

      /// AppTrackingTransparency.getAdvertisingIdentifier();
    } on PlatformException catch (e) {
      printLog('[App Tracking Transparency] Unexpected Platform Exception: $e');
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await loadInitData();
  }

  @override
  Widget build(BuildContext context) {
    var splashScreenType = kSplashScreenType;
    dynamic splashScreenData = kSplashScreen;

    return SplashScreenIndex(
      imageUrl: splashScreenData,
      splashScreenType: splashScreenType,
      actionDone: checkToShowNextScreen,
    );
  }
}
