import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard, StoryWidget;
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../common/tools.dart';
// import '../frameworks/vendor/route.dart';
import '../menu/maintab.dart';
import '../models/index.dart' show Product, SearchModel, User;
import '../modules/dynamic_layout/config/app_config.dart';
import '../modules/dynamic_layout/search/home_search_page.dart';
import '../screens/checkout/checkoutV3/checkout_screenV3.dart';
import '../screens/index.dart';
import '../screens/my_thingi/thingi_screen.dart';
import '../screens/order_history/index.dart';
import '../screens/pages/static_page.dart';
import '../screens/user_update/user_update_screen.dart';
import '../screens/user_update/user_update_woo_screen.dart';
import '../services/index.dart';
import '../widgets/blog/slider_list.dart';

export 'route_observer.dart';

class Routes {
  static Map<String, WidgetBuilder> getAll() => _routes;

  static final Map<String, WidgetBuilder> _routes = {
    RouteList.dashboard: (context) => MainTabs(),
    RouteList.register: (context) => RegistrationScreen(),
    RouteList.products: (context) => ProductsScreen(),
    // RouteList.wishlist: (context) => WishListScreen(), // Original
    RouteList.wishlist: (context) => const ThingiPage(), // Original
    RouteList.checkout: (context) => Checkout(),
    RouteList.checkoutV3: (context) => const CheckoutScreenV3(), // My
    RouteList.notify: (context) => NotificationScreen(),
    RouteList.language: (context) => LanguageScreen(),
    RouteList.currencies: (context) => CurrenciesScreen(),
    RouteList.category: (context) => CategoriesScreen(),
    RouteList.search: (context) => ChangeNotifierProvider(
          create: (_) => SearchModel(),
          child: SearchScreen(),
        ),
    RouteList.updateUser: (context) {
      if (Config().isWooType) {
        return UserUpdateWooScreen();
      }
      return UserUpdateScreen();
    },
  };

  static Route getRouteGenerate(RouteSettings settings) {
    var routingData = settings.name!.getRoutingData;

    printLog('[🧬Builder RouteGenerate] ${routingData.route}');

    switch (routingData.route) {
      case RouteList.homeSearch:
        return _buildRouteFade(
          settings,
          ChangeNotifierProvider(
            create: (context) => SearchModel(),
            child: HomeSearchPage(),
          ),
        );
      case RouteList.productDetail:
        Product? product;

        /// The product detail is product
        if (settings.arguments is Product) {
          product = settings.arguments as Product?;
          return _buildRoute(
            settings,
            (_) => ProductDetailScreen(product: product, id: product!.id),
          );
        }

        /// The product detail is ID
        var productId = routingData.getPram('id');
        if (productId != null) {
          return _buildRoute(
            settings,
            (_) => ProductDetailScreen(id: productId),
          );
        }
        return _errorRoute();
      case RouteList.category:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => CategoriesScreen(
              key: const Key('category'),
              showSearch: data.jsonData['showSearch'] ?? true,
            ),
          );
        }
        return _errorRoute();
      case RouteList.categorySearch:
        return _buildRouteFade(
          settings,
          CategorySearch(),
        );
      case RouteList.detailBlog:
        final blog = settings.arguments;
        if (blog is Blog) {
          return _buildRoute(settings, (_) => BlogDetailScreen(blog: blog));
        }
        return _errorRoute();
      case RouteList.orderDetail:
        final orderHistoryModel = settings.arguments;
        if (orderHistoryModel is OrderHistoryDetailModel) {
          return _buildRoute(
            settings,
            (_) {
              return ChangeNotifierProvider<OrderHistoryDetailModel>.value(
                value: orderHistoryModel,
                child: OrderHistoryDetailScreen(),
              );
            },
          );
        }
        return _errorRoute();
      case RouteList.orders:
        final user = settings.arguments;
        return _buildRoute(
          settings,
          (_) => ChangeNotifierProvider<ListOrderHistoryModel>(
            create: (context) => ListOrderHistoryModel(
              repository: ListOrderRepository(
                  user: user == null ? User() : user as User),
            ),
            child: ListOrderHistoryScreen(),
          ),
        );
      case RouteList.search:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => AutoHideKeyboard(
              child: ChangeNotifierProvider<SearchModel>(
                create: (context) => SearchModel(),
                builder: (context, _) {
                  return Services().widget.renderSearchScreen(
                        context,
                        showChat: data.jsonData['showChat'],
                      );
                },
              ),
            ),
          );
        }
        return _errorRoute();
      case RouteList.profile:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => SettingScreen(
              settings: data.jsonData['settings'],
              background: data.jsonData['background'],
            ),
          );
        }
        return _errorRoute();
      case RouteList.blog:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (_) => HorizontalSliderList(config: data as Map<String, dynamic>?),
          );
        }
        return _errorRoute();
      case RouteList.blogs:
        return _buildRoute(
          settings,
          (_) => ListBlogScreen(),
        );
      case RouteList.page:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (_) => WebViewScreen(
              title: data['title'],
              url: data['url'],
            ),
          );
        }
        return _errorRoute();
      case RouteList.html:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (_) => StaticSite(data: data['data']),
          );
        }
        return _errorRoute();
      case RouteList.static:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (_) => StaticPage(
              data: data['data'],
            ),
          );
        }
        return _errorRoute();
      case RouteList.postScreen:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (_) => PostScreen(
              pageId: int.parse(data['pageId'].toString()),
              pageTitle: data['pageTitle'],
              isLocatedInTabbar: true,
            ),
          );
        }
        return _errorRoute();
      case RouteList.story:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (context) => StoryWidget(
              config: data as Map<String, dynamic>,
              isFullScreen: true,
              onTapStoryText: (cfg) {
                NavigateTools.onTapNavigateOptions(
                    context: context, config: cfg);
              },
            ),
          );
        }
        return _errorRoute();
      case RouteList.vendors:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (context) =>
                Services().widget.renderVendorCategoriesScreen(data.jsonData),
          );
        }
        return _errorRoute();
      case RouteList.map:
        return _buildRoute(
          settings,
          (context) => Services().widget.renderMapScreen(),
        );
      case RouteList.vendorDashboard:
        return _buildRoute(
          settings,
          (context) => Services().widget.renderVendorDashBoard(),
        );
      case RouteList.dynamic:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (context) => DynamicScreen(
                configs: data['configs'], previewKey: data['key']),
          );
        }
        return _errorRoute();
      case RouteList.home:
        return _buildRoute(
          settings,
          (context) => const HomeScreen(),
        );
      case RouteList.login:
        final fromCart = settings.arguments as bool? ?? false;
        return _buildRoute(
          settings,
          (context) => LoginScreen(fromCart: fromCart),
        );
      case RouteList.loginSMS:
        final fromCart = settings.arguments as bool? ?? false;
        return _buildRoute(
          settings,
          (context) => LoginSMSScreen(fromCart: fromCart),
        );
      case RouteList.onBoarding:
        return _buildRoute(
          settings,
          (context) => OnBoardScreen(),
        );
      case RouteList.cart:
        final cartArgument = settings.arguments;
        if (cartArgument is CartScreenArgument) {
          return _buildRoute(
            settings,
            (context) => CartScreen(
              isBuyNow: cartArgument.isBuyNow,
              isModal: cartArgument.isModal,
            ),
            fullscreenDialog: true,
          );
        }
        return _buildRoute(
          settings,
          (context) => CartScreen(),
        );
      default:
        if (_routes.containsKey(settings.name)) {
          return _buildRoute(
            settings,
            _routes[settings.name!]!,
          );
        }
        // if (Config().isVendorType()) {
        //   return _buildRoute(
        //       settings, VendorRoute.getRoutesWithSettings(settings)!);
        // }
        return _errorRoute();
    }
  }

  static WidgetBuilder? getRouteByName(String name) {
    if (_routes.containsKey(name) == false) {
      return _routes[RouteList.login];
    }
    return _routes[name];
  }

  static Route _errorRoute([String message = 'Page not found']) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(message),
        ),
      );
    });
  }

  static PageRouteBuilder _buildRouteFade(
    RouteSettings settings,
    Widget builder,
  ) {
    return _FadedTransitionRoute(
      settings: settings,
      widget: builder,
    );
  }

  static MaterialPageRoute _buildRoute(
      RouteSettings settings, WidgetBuilder builder,
      {bool fullscreenDialog = false}) {
    return MaterialPageRoute(
      settings: settings,
      builder: builder,
      fullscreenDialog: fullscreenDialog,
    );
  }
}

class _FadedTransitionRoute extends PageRouteBuilder {
  final Widget? widget;
  @override
  final RouteSettings settings;

  _FadedTransitionRoute({this.widget, required this.settings})
      : super(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget!;
          },
          transitionDuration: const Duration(milliseconds: 100),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        );
}
