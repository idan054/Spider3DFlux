
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:fstore/screens/my_thingi/thingi_screen.dart';
import 'package:fstore/screens/users/spider_point_screen.dart';
import 'package:inspireui/widgets/flux_image.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Address, AppModel, CartModel, User, UserModel, WishListModel;
import '../../models/notification_model.dart';
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/common/webview.dart';
import '../users/user_point_screen.dart';


class SettingScreen extends StatefulWidget {
  final List<dynamic>? settings;
  final String? background;
  final VoidCallback? onLogout;

  SettingScreen({
    this.onLogout,
    this.settings,
    this.background,
  });

  @override
  _SettingScreenState createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SettingScreen> {
  @override
  bool get wantKeepAlive => true;

  User? get user => Provider.of<UserModel>(context, listen: false).user;

  bool showSpider = false;
  final bannerHigh = 150.0;
  final RateMyApp _rateMyApp = RateMyApp(
      // rate app on store
      minDays: 7,
      minLaunches: 10,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: kStoreIdentifier['android'],
      appStoreIdentifier: kStoreIdentifier['ios']);

  void showRateMyApp() {
    _rateMyApp.showRateDialog(
      context,
      title: S.of(context).rateTheApp,
      // The dialog title.
      message: S.of(context).rateThisAppDescription,
      // The dialog message.
      rateButton: S.of(context).rate.toUpperCase(),
      // The dialog 'rate' button text.
      noButton: S.of(context).noThanks.toUpperCase(),
      // The dialog 'no' button text.
      laterButton: S.of(context).maybeLater.toUpperCase(),
      // The dialog 'later' button text.
      listener: (button) {
        // The button click listener (useful if you want to cancel the click event).
        switch (button) {
          case RateMyAppDialogButton.rate:
            break;
          case RateMyAppDialogButton.later:
            break;
          case RateMyAppDialogButton.no:
            break;
        }

        return true; // Return false if you want to cancel the click event.
      },
      // Set to false if you want to show the native Apple app rating dialog on iOS.
      dialogStyle: const DialogStyle(),
      // Custom dialog styles.
      // Called when the user dismissed the dialog (either by taping outside or by pressing the 'back' button).
      // actionsBuilder: (_) => [], // This one allows you to use your own buttons.
    );
  }

  @override
  void initState() {
    if (isMobile) {
      _rateMyApp.init().then((_) {
        // state of rating the app
        if (_rateMyApp.shouldOpenDialog) {
          showRateMyApp();
        }
      });
    }
    super.initState();
  }

  /// Render the Admin Vendor Menu.
  /// Currently support WCFM & Dokan. Will support WooCommerce soon.
  Widget renderVendorAdmin() {
    if (kFluxStoreMV.contains(serverConfig['type']) &&
        (user?.isVender ?? false)) {
      return const SizedBox();
    }

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          final langCode =
              Provider.of<AppModel>(context, listen: false).langCode;

          if (unsupportedLanguages.contains(langCode)) {
            final snackBar = SnackBar(
              content: Text(
                  S.of(context).thisFeatureDoesNotSupportTheCurrentLanguage),
              duration: const Duration(seconds: 1),
            );
            // ignore: deprecated_member_use
            Scaffold.of(context).showSnackBar(snackBar);
            return;
          }
          FluxNavigate.push(
            MaterialPageRoute(
              builder: (context) =>
                  Services().widget.getAdminVendorScreen(context, user)!,
            ),
            forceRootNavigator: true,
          );
        },
        leading: Icon(
          Icons.dashboard,
          size: 24,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          S.of(context).vendorAdmin,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }

  /// Render the custom profile link via Webview
  /// Example show some special profile on the woocommerce site: wallet, wishlist...
  Widget renderWebViewProfile() {
    if (user == null) {
      return Container();
    }

    var base64Str = EncodeUtils.encodeCookie(user!.cookie!);
    var profileURL = '${serverConfig['url']}/my-account?cookie=$base64Str';

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebView(
                  url: profileURL, title: S.of(context).updateUserInfor),
            ),
          );
        },
        leading: Icon(
          CupertinoIcons.profile_circled,
          size: 24,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          S.of(context).updateUserInfor,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).accentColor,
          size: 18,
        ),
      ),
    );
  }

  Widget renderItem(value) {
    Widget icon;
    String title;
    Widget trailing;
    Widget spiderWidget = Container();
    Function() onTap;
    var isMultiVendor = kFluxStoreMV.contains(serverConfig['type']);
    switch (value) {
      case 'products':
        {
          if (!(user != null ? user!.isVender : false)) {
            return Container();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).myProducts;
          icon = Icon(CupertinoIcons.cube_box,
              color: Theme.of(context).accentColor, size: 24);
          onTap = () => Navigator.pushNamed(context, RouteList.productSell);
          break;
        }

      case 'chat':
        {
          if (user == null || Config().isListingType || !isMultiVendor) {
            return Container();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).conversations;
          icon = Icon(CupertinoIcons.chat_bubble_2,
              color: Theme.of(context).accentColor, size: 24);
          onTap = () => Navigator.pushNamed(context, RouteList.listChat);
          break;
        }
      case 'wishlist':
        {
          final wishListCount =
              Provider.of<WishListModel>(context, listen: false)
                  .products
                  .length;
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (wishListCount > 0)
                Text(
                  '$wishListCount ${S.of(context).items}',
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).primaryColor),
                ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600)
            ],
          );

          title = S.of(context).myWishList;
          icon = Icon(CupertinoIcons.heart,
              color: Theme.of(context).accentColor, size: 24);
          onTap = () => Navigator.of(context).pushNamed(RouteList.wishlist);
          break;
        }
      case 'notifications':
        {
          if (Config().isBuilder) {
            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 2.0),
                  elevation: 0,
                  child: SwitchListTile(
                    secondary: Icon(
                      CupertinoIcons.bell,
                      color: Theme.of(context).accentColor,
                      size: 24,
                    ),
                    value: false,
                    activeColor: const Color(0xFF0066B4),
                    onChanged: (bool enableNotification) {},
                    title: Text(
                      S.of(context).getNotification,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                spiderWidget,
                const Divider(
                  color: Colors.black12,
                  height: 1.0,
                  indent: 75,
                  //endIndent: 20,
                ),
              ],
            );
          }
          return Consumer<NotificationModel>(builder: (context, model, child) {
            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 2.0),
                  elevation: 0,
                  child: SwitchListTile(
                    secondary: Icon(
                      CupertinoIcons.bell,
                      color: Theme.of(context).accentColor,
                      size: 24,
                    ),
                    value: model.enable,
                    activeColor: const Color(0xFF0066B4),
                    onChanged: (bool enableNotification) {
                      if (enableNotification) {
                        model.enableNotification();
                      } else {
                        model.disableNotification();
                      }
                    },
                    title: Text(
                      S.of(context).getNotification,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black12,
                  height: 1.0,
                  indent: 75,
                  //endIndent: 20,
                ),
                if (model.enable) ...[
                  Card(
                    margin: const EdgeInsets.only(bottom: 2.0),
                    elevation: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteList.notify);
                      },
                      child: ListTile(
                        leading: Icon(
                          CupertinoIcons.list_bullet,
                          size: 22,
                          color: Theme.of(context).accentColor,
                        ),
                        title: Text(S.of(context).listMessages),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: kGrey600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.black12,
                    height: 1.0,
                    indent: 75,
                    //endIndent: 20,
                  ),
                ],
              ],
            );
          });
        }
      case 'language':
        {
          icon = Icon(CupertinoIcons.globe,
              color: Theme.of(context).accentColor, size: 24);
          title = S.of(context).language;
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          onTap = () => Navigator.of(context).pushNamed(RouteList.language);
          break;
        }
      case 'currencies':
        {
          if (Config().isListingType) {
            return Container();
          }
          icon = Icon(CupertinoIcons.money_dollar_circle,
              color: Theme.of(context).accentColor, size: 24);
          title = S.of(context).currencies;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.of(context).pushNamed(RouteList.currencies);
          break;
        }
      case 'darkTheme':
        {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 2.0),
                elevation: 0,
                child: SwitchListTile(
                  secondary: Icon(
                    Provider.of<AppModel>(context).darkTheme
                        ? CupertinoIcons.sun_min
                        : CupertinoIcons.moon,
                    color: Theme.of(context).accentColor,
                    size: 24,
                  ),
                  value: Provider.of<AppModel>(context).darkTheme,
                  activeColor: const Color(0xFF0066B4),
                  onChanged: (bool value) {
                    if (value) {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(true);
                    } else {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(false);
                    }
                  },
                  title: Text(
                    S.of(context).darkTheme,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black12,
                height: 1.0,
                indent: 75,
                //endIndent: 20,
              ),
            ],
          );
        }
      case 'order':
        {
          final storage = LocalStorage('data_order');
          var items = storage.getItem('orders');
          if (user == null && items == null) {
            return Container();
          }
          if (Config().isListingType) {
            return const SizedBox();
          }
          icon = Icon(CupertinoIcons.time,
              color: Theme.of(context).accentColor, size: 24);
          title = S.of(context).orderHistory;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            final user = Provider.of<UserModel>(context, listen: false).user;
            FluxNavigate.pushNamed(
              RouteList.orders,
              arguments: user,
            );
          };
          break;
        }
      case 'point':
        {
          if (!(kAdvanceConfig['EnablePointReward'] == true && user != null)) {
            return const SizedBox();
          }
          if (Config().isListingType) {
            return const SizedBox();
          }
          icon = Icon(CupertinoIcons.bag_badge_plus,
              color: Theme.of(context).accentColor, size: 24);
          title = S.of(context).myPoints;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPointScreen(),
                ),
              );
          break;
        }
      case 'rating':
        {
          icon = Icon(CupertinoIcons.star,
              color: Theme.of(context).accentColor, size: 24);
          title = S.of(context).rateTheApp;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = showRateMyApp;
          break;
        }
      case 'spiders':
        {
          // icon = CupertinoIcons.money_dollar_circle;
          icon = Transform.translate(
              offset: const Offset(0, 0),
              child: Image.asset('assets/images/spider_coin.png',
                  // color: kGrey600, height: 24, width: 24));
                  color: Theme.of(context).accentColor,
                  height: 24,
                  width: 24));
          // title = S.of(context).aboutUs;
          title = 'קאשבק & ספיידרס';

          // User? get user => Provider.of<UserModel>(context, listen: false).user;
          // final user = Provider.of<UserModel>(context, listen: false).user;
          final user_email =
              Provider.of<UserModel>(context).user!.email.toString();

          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            print(showSpider);
            setState(() {
              // showSpider = false;
              showSpider = !showSpider;
            });
            print("showSpider:");
            print(showSpider);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpidersPointScreen(),
              ),
            );
          };

          // spiderWidget = ClipRRect(
          //   borderRadius: BorderRadius.circular(5.0),
          //   child: AnimatedContainer(
          //     padding: const EdgeInsets.all(10.0),
          //     width: MediaQuery.of(context).size.width,
          //     height: showSpider ? 70 : 0.0,
          //     color: Colors.grey[200],
          //     duration: const Duration(seconds: 1),
          //     curve: Curves.fastOutSlowIn,
          //     child: Center(
          //       child: FutureBuilder<String>(
          //         future: my_Woorewards(
          //             user_email: 'eyal@kivi.co.il'), // async work
          //         builder:
          //             (BuildContext context, AsyncSnapshot<String> snapshot) {
          //           switch (snapshot.connectionState) {
          //             case ConnectionState.waiting:
          //               return const Text('Loading....');
          //             default:
          //               if (snapshot.hasError) {
          //                 return Text('Error: ${snapshot.error}');
          //               } else {
          //                 return Text('Result: ${snapshot.data}');
          //               }
          //           }
          //         },
          //       ),
          //       // Text('${spiderPoints.toString()}')
          //       // Text('יש לך 30 ספיידרס ששווים 3₪ \nהקאשבק שלך יופעל אוטומטית ברכישה הבאה.')
          //     ),
          //   ),
          // );

          // Opens webView (That require login again)
          // onTap = () {
          //   if (kIsWeb) {
          //     return Tools.launchURL(SettingConstants.spidersUrl);
          //   }
          //   return FluxNavigate.push(
          //     MaterialPageRoute(
          //       builder: (context) =>
          //           WebView(url: SettingConstants.spidersUrl, title: title),
          //     ),
          //     forceRootNavigator: true,
          //   );
          // };
          break;
        }
      case 'about':
        {
          icon = Icon(CupertinoIcons.info,
              color: Theme.of(context).accentColor, size: 24);
          title = S.of(context).aboutUs;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            if (kIsWeb) {
              return Tools.launchURL(SettingConstants.aboutUsUrl);
            }
            return FluxNavigate.push(
              MaterialPageRoute(
                builder: (context) => WebView(
                    url: SettingConstants.aboutUsUrl,
                    title: S.of(context).aboutUs),
              ),
              forceRootNavigator: true,
            );
          };
          break;
        }
      default:
        {
          icon =
              Icon(Icons.error, color: Theme.of(context).accentColor, size: 24);
          title = S.of(context).dataEmpty;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {};
          break;
        }
    }

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 2.0),
          elevation: 0,
          child: ListTile(
            leading: icon,
            title: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
        spiderWidget,
        const Divider(
          color: Colors.black12,
          height: 1.0,
          indent: 75,
          //endIndent: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenSize = MediaQuery.of(context).size;
    var settings = widget.settings ?? kDefaultSettings;
    var background = widget.background ?? kProfileBackground;
    const textStyle = TextStyle(fontSize: 16);
    // final myUserModel = Provider.of<UserModel>(context, listen: false).user!.loggedIn.toString();

    return
        // Center(child: Text(myUserModel.user!.loggedIn.toString()));
        Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListenableProvider.value(
        value: Provider.of<UserModel>(context),
        child: Consumer<UserModel>(builder: (context, model, child) {
          final user = model.user;
          final loggedIn = model.loggedIn;
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Theme.of(context).primaryColor,
                leading: IconButton(
                  tooltip: '${Constants.thingiToken_counter} | thingiToken ${Constants.thingiToken}',
                  icon: Icon(
                    // Icons.blur_on,
                    Icons.menu,
                    // color: Colors.wh11ite70,
                    // color: Colors.black87,
                    color: Theme.of(context)
                        .tabBarTheme
                        .labelColor!
                        .withOpacity(0.7),
                  ),
                  onPressed: () => NavigateTools.onTapOpenDrawerMenu(context),
                ),
                expandedHeight: bannerHigh,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      S.of(context).settings,
                      style: TextStyle(
                          fontSize: 18,
                          // color: Colors.white,
                          color: Theme.of(context).tabBarTheme.labelColor,
                          fontWeight: FontWeight.w600),
                    ),
                    background: Container(
                      color: Theme.of(context).backgroundColor,
                      child: const Center(
                          child: FluxImage(
                              imageUrl: 'https://i.imgur.com/LQWSjzt.png',
                              height: 50)),
                    )
                    // Image.network(
                    //   background,
                    //   fit: BoxFit.cover,
                    // ),
                    ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    Container(
                      width: screenSize.width,
                      child: Container(
                        width: screenSize.width /
                            (2 / (screenSize.height / screenSize.width)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 10.0),
                              if (user != null && user.name != null)
                                ListTile(
                                  leading: (user.picture?.isNotEmpty ?? false)
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user.picture!),
                                        )
                                      : Icon(Icons.face,
                                          color: Theme.of(context).accentColor),
                                  title: Text(
                                    user.name!.replaceAll('fluxstore', ''),
                                    style: textStyle,
                                  ),
                                ),
                              if (user != null && user.email != null)
                                ListTile(
                                  leading:
                                      // Icon(Icons.email),
                                      Icon(
                                    // Icons.email_outlined,
                                    Icons.alternate_email,
                                    color: Theme.of(context).accentColor,
                                    size: 25,
                                  ),
                                  title: Text(
                                    user.email!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              if (user != null)
                                Card(
                                  color: Theme.of(context).backgroundColor,
                                  margin: const EdgeInsets.only(bottom: 2.0),
                                  elevation: 0,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.portrait,
                                      color: Theme.of(context).accentColor,
                                      size: 25,
                                    ),
                                    title: Text(
                                      S.of(context).updateUserInfor,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: kGrey600,
                                    ),
                                    onTap: () {
                                      FluxNavigate.pushNamed(
                                        RouteList.updateUser,
                                        forceRootNavigator: true,
                                      );
                                    },
                                  ),
                                ),
                              if (user == null)
                                Card(
                                  color: Theme.of(context).backgroundColor,
                                  margin: const EdgeInsets.only(bottom: 2.0),
                                  elevation: 0,
                                  child: ListTile(
                                    onTap: () {
                                      if (!loggedIn) {
                                        Navigator.of(
                                          App.fluxStoreNavigatorKey
                                              .currentContext!,
                                        ).pushNamed(RouteList.login);
                                        return;
                                      }
                                      Provider.of<UserModel>(context,
                                              listen: false)
                                          .logout();
                                      if (kLoginSetting['IsRequiredLogin'] ??
                                          false) {
                                        Navigator.of(
                                          App.fluxStoreNavigatorKey
                                              .currentContext!,
                                        ).pushNamedAndRemoveUntil(
                                          RouteList.login,
                                          (route) => false,
                                        );
                                      }
                                    },
                                    leading: const Icon(Icons.person),
                                    title: Text(
                                      loggedIn
                                          ? S.of(context).logout
                                          : S.of(context).login,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: kGrey600),
                                  ),
                                ),
                              if (user != null)
                                Card(
                                  color: Theme.of(context).backgroundColor,
                                  margin: const EdgeInsets.only(bottom: 2.0),
                                  elevation: 0,
                                  child: ListTile(
                                    onTap: () async {
                                      await Provider.of<UserModel>(context,
                                              listen: false).logout();
                                      if (kLoginSetting['IsRequiredLogin'] ??
                                          false) {
                                        await Navigator.of(App
                                                .fluxStoreNavigatorKey
                                                .currentContext!)
                                            .pushNamedAndRemoveUntil(
                                          RouteList.login,
                                          (route) => false,
                                        );
                                      }

                                      // My show / clear all SharedPreferences data
                                      var prefs =
                                          await SharedPreferences.getInstance();

                                      print(
                                          'loadInitData - prefs.getKeys ${prefs.getKeys()}');
                                      await prefs.remove('loggedIn');
                                      await prefs.clear(); // remove all ces.getInstance() data
                                      await prefs.setBool('seen', true);

                                      final fstore_storage =
                                          LocalStorage('fstore');
                                      final address_storage =
                                          LocalStorage('address');
                                      final data_order_storage =
                                          LocalStorage('data_order');

                                      await fstore_storage.clear();
                                      await address_storage.clear();
                                      await data_order_storage.clear();

                                      Provider.of<CartModel>(context).dispose();
                                      // Provider.of<AppModel>(context).dispose();


                                    },
                                    leading: Icon(
                                      Icons.logout,
                                      size: 20,
                                      color: Theme.of(context).accentColor,
                                    ),

                                    // Image.asset(
                                    //   'assets/icons/profile/icon-logout.png',
                                    //   width: 24,
                                    //   color: Theme.of(context).accentColor,
                                    // ),
                                    title: Text(
                                      S.of(context).logout,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: kGrey600),
                                  ),
                                ),
                              const SizedBox(height: 30.0),
                              Text(
                                S.of(context).generalSetting,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10.0),

                              /// Render some extra menu for Vendor.
                              /// Currently support WCFM & Dokan. Will support WooCommerce soon.
                              if (kFluxStoreMV.contains(serverConfig['type']) &&
                                  (user?.isVender ?? false)) ...[
                                renderVendorAdmin(),
                                Services().widget.renderVendorOrder(context),
                              ],

                              /// Render custom Wallet feature
                              // renderWebViewProfile(),

                              /// render some extra menu for Listing
                              if (user != null && Config().isListingType) ...[
                                Services().widget.renderNewListing(context),
                                Services().widget.renderBookingHistory(context),
                              ],

                              const SizedBox(height: 10.0),
                              if (user != null)
                                const Divider(
                                  color: Colors.black12,
                                  height: 1.0,
                                  indent: 75,
                                  //endIndent: 20,
                                ),

                              /// render list of dynamic menu
                              /// this could be manage from the Fluxbuilder
                              ...List.generate(
                                settings.length,
                                (index) {
                                  return renderItem(settings[index]);
                                },
                              ),
                              const SizedBox(height: 100)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
