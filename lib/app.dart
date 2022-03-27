import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fstore/screens/checkout/checkoutV3/RadioButtonV3.dart';
import 'package:fstore/screens/checkout/checkoutV3/checkoutV3_provider.dart';
import 'package:fstore/screens/checkout/checkoutV3/checkout_screenV3.dart';
import 'package:fstore/screens/my_thingi/set_thingitoken.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart';
import 'app_init.dart';
import 'common/config.dart';
import 'common/constants.dart';
import 'common/theme/index.dart';
import 'common/tools.dart';
import 'generated/l10n.dart';
import 'generated/languages/index.dart';
import 'models/index.dart';
import 'models/notification_model.dart';
import 'routes/route.dart';
import 'screens/blog/models/list_blog_model.dart';
import 'services/dependency_injection.dart';
import 'services/index.dart';
import 'services/notification/notification_service.dart';
import 'widgets/overlay/custom_overlay_state.dart';

class App extends StatefulWidget {
  final String languageCode;

  App({
    required this.languageCode,
  });

  static final GlobalKey<NavigatorState> fluxStoreNavigatorKey = GlobalKey();

  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App>
    with WidgetsBindingObserver
    implements NotificationDelegate, UserModelDelegate {
  AppModel? _app; //
  final _product = ProductModel(); //
  final _tagModel = TagModel();
  final _wishlist = WishListModel();
  final _shippingMethod = ShippingMethodModel();
  final _paymentMethod = PaymentMethodModel();
  final _recent = RecentModel();
  final _user = UserModel(); //
  final _filterModel = FilterAttributeModel();
  final _filterTagModel = FilterTagModel();
  final _categoryModel = CategoryModel();
  final _taxModel = TaxModel();
  // final _pointModel = PointModel();
  final _notificationModel = NotificationModel();

  /// ---------- Vendor -------------
  StoreModel? _storeModel;
  VendorShippingMethodModel? _vendorShippingMethodModel;

  /// -------- Listing ------------///
  // final _listingLocationModel = ListingLocationModel();

  CartInject cartModel = CartInject();
  bool isFirstSeen = false;
  bool isLoggedIn = true;

  late var firebaseAnalyticsAbs;

  void appInitialModules() {
    var startTime = DateTime.now();

    firebaseAnalyticsAbs = Services().firebase.getAnalytic()..init();
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        _user.delegate = this;
        final notificationService = injector<NotificationService>();
        notificationService.init(
          notificationDelegate: this,
          externalUserId: 'Loc',
        );

        printLog(
            '[AppState] Register Firebase or OneSignal Moduless', startTime);
      },
    );
  }

  /// Build the App Theme
  ThemeData getTheme(context) {
    var appModel = Provider.of<AppModel>(context);
    var isDarkTheme = appModel.darkTheme;

    if (appModel.appConfig == null) {
      /// This case is loaded first time without config file
      return buildLightTheme(appModel.langCode);
    }

    var fontFamily = appModel.appConfig!.settings.fontFamily;

    if (isDarkTheme) {
      return buildDarkTheme(appModel.langCode, fontFamily).copyWith(
        primaryColor: HexColor(
          appModel.mainColor,
        ),
      );
    }
    return buildLightTheme(appModel.langCode, fontFamily).copyWith(
      // primaryColor: HexColor(appModel.mainColor),
      primaryColor: kColorSpiderRed,
    );
  }

  Future<void> updateDeviceToken(User? user) async {
    if (GmsTools().isGmsAvailable) {
      await Services().firebase.getMessagingToken().then((token) async {
        try {
          await Services()
              .api
              .updateUserInfo({'deviceToken': token}, user!.cookie);
          print('app.dart - updateDeviceToken() - token $token');
        } catch (e) {
          printLog(e);
        }
      });
    }
  }
  AppUpdateInfo? _updateInfo;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then((info) {
      _updateInfo = info;
      log('update details'
          '\n${info.updateAvailability},'
          '\n${info.availableVersionCode},'
          '\n${info.packageName},'
          '\n${info.flexibleUpdateAllowed},'
          '\n${info.immediateUpdateAllowed}'
          '\n${info.updatePriority},'
          '\n${info.toString()},'
          );
      if(_updateInfo!=null){
        if(_updateInfo!.updateAvailability == 2) {
          if (_updateInfo!.immediateUpdateAllowed) {
            InAppUpdate.performImmediateUpdate();
          }
          InAppUpdate.startFlexibleUpdate();
        }
      }
    }).catchError((e) {
    });
  }


  @override
  void initState() {
    printLog('[AppState] initState');
    checkForUpdate();
    _app = AppModel(widget.languageCode);
    WidgetsBinding.instance?.addObserver(this);

    if (!kIsWeb) {
      appInitialModules();
    }
    super.initState();
  }

  @override
  Future<void> onLoaded(User? user) async {
    await updateDeviceToken(user);

    // user?.id != null
    print('app.dart - onLoaded() - user?.id ${user?.id}');
    await set_thingiToken();

    /// init Cart Modal
    cartModel.model.changeCurrencyRates(_app?.currencyRate);

    /// save logged in user
    cartModel.model.setUser(user);
    if (user?.cookie != null &&
        (kAdvanceConfig['EnableSyncCartFromWebsite'] ?? true)) {
      await Services()
          .widget
          .syncCartFromWebsite(user?.cookie, cartModel.model, context);
    }

    // if (user?.cookie != null && (kAdvanceConfig['EnablePointReward'] ?? true)) {
    //   await _pointModel.getMyPoint(user?.cookie);
    // }

    /// Preload address.
    await cartModel.model.getAddress();
  }

  @override
  Future<void> onLoggedIn(User user) async => onLoaded(user);

  @override
  Future<void> onLogout(User? user) async {
    cartModel.model.clearCart();
    await _wishlist.clearWishList();
    if (Services().firebase.isEnabled) {
      try {
        await Services().api.updateUserInfo({'deviceToken': ''}, user!.cookie);
      } catch (e) {
        printLog(e);
      }
    }
  }

  @override
  void onTapMessage(FStoreNotificationItem notification) {}

  @override
  void onMessage(FStoreNotificationItem notification) {
    printLog(notification.toJson());
    _notificationModel.saveMessage(notification);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _notificationModel.checkGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    printLog('[AppState] Build app.dart');
    return ChangeNotifierProvider<AppModel>.value(
      value: _app!,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          var languageCode = value.langCode!.isEmptyOrNull
              ? kAdvanceConfig['DefaultLanguage']
              : value.langCode;

          if (value.vendorType == VendorType.multi &&
              _storeModel == null &&
              _vendorShippingMethodModel == null) {
            _storeModel = StoreModel();
            _vendorShippingMethodModel = VendorShippingMethodModel();
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: MultiProvider(
              providers: [
                Provider<ProductModel>.value(value: _product),
                Provider<WishListModel>.value(value: _wishlist),
                Provider<ShippingMethodModel>.value(value: _shippingMethod),
                Provider<PaymentMethodModel>.value(value: _paymentMethod),
                Provider<RecentModel>.value(value: _recent),
                Provider<UserModel>.value(value: _user),
                ChangeNotifierProvider<CheckoutProviderV3>(create: (_) => CheckoutProviderV3()), // my
                ChangeNotifierProvider<ListBlogModel>(create: (_) => ListBlogModel()),
                ChangeNotifierProvider<FilterAttributeModel>(
                    create: (_) => _filterModel),
                ChangeNotifierProvider<FilterTagModel>(
                    create: (_) => _filterTagModel),
                ChangeNotifierProvider<CategoryModel>(
                    create: (_) => _categoryModel),
                ChangeNotifierProvider(create: (_) => _tagModel),
                ChangeNotifierProvider(
                    create: (_) => cartModel.model, lazy: true),
                Provider<TaxModel>.value(value: _taxModel),
                ChangeNotifierProvider.value(value: _notificationModel),
                if (value.vendorType == VendorType.multi) ...[
                  ChangeNotifierProvider<StoreModel>(
                      create: (_) => _storeModel!),
                  ChangeNotifierProvider<VendorShippingMethodModel>(
                      create: (_) => _vendorShippingMethodModel!),
                ],
                // Provider<PointModel>.value(value: _pointModel),
                // if (Config().isListingType) ...[
                //   ChangeNotifierProvider<ListingLocationModel>(
                //       create: (_) => _listingLocationModel)
                // ]
              ],
              child: MaterialApp(
                // debugShowCheckedModeBanner: false,
                locale: Locale(
                    languageCode ?? kAdvanceConfig['DefaultLanguage'], ''),
                navigatorKey: App.fluxStoreNavigatorKey,
                navigatorObservers: [
                  MyRouteObserver(
                      action: (screenName) =>
                          OverlayControlDelegate().emitRoute?.call(screenName)),
                  ...firebaseAnalyticsAbs.getMNavigatorObservers()
                ],
                localizationsDelegates: [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate,
                  LocalWidgetLocalizations.delegate,
                  SubMaterialLocalizations.delegate,
                  SubCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
              //   home: UpgradeAlert(
              //   dialogStyle: UpgradeDialogStyle.cupertino,
              //   countryCode: 'IL',
              //   debugLogging: true,
              //   child: const Scaffold(body: AppInit()),
              // ),
                home: UpgradeAlert(
                  dialogStyle: UpgradeDialogStyle.cupertino,
                  countryCode: 'IL',
                  child: const Scaffold(body: AppInit()),
                ),
                // home: const CheckoutScreenV3(),
                routes: Routes.getAll(),
                debugShowCheckedModeBanner: false,
                onGenerateRoute: Routes.getRouteGenerate,
                theme: getTheme(context),
                themeMode: value.themeMode,
              ),
            ),
          );
        },
      ),
    );
  }
}
