import '../../models/index.dart'
    show
    AddonsOption,
    AppModel,
    CartModel,
    Country,
    CountryState,
    Coupons,
    Discount,
    ListCountry,
    Order,
    PaymentMethod,
    PaymentMethodModel,
    Product,
    ProductVariation,
    ShippingMethodModel,
    TaxModel,
    User,
    UserModel;

// index.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstore/frameworks/woocommerce/services/woo_commerce.dart';
import 'package:fstore/screens/checkout/checkoutV3/checkoutV3_provider.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/entities/order.dart';
import '../../screens/index.dart'

    show Checkout, MyCart, PaymentWebview, SuccessScreen;
import '../../services/index.dart';
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'product_addons_mixin.dart';
import 'woo_variant_mixin.dart';

import 'package:localstorage/localstorage.dart';

class WooWidget extends BaseFrameworks
    with ProductVariantMixin, WooVariantMixin, ProductAddonsMixin {
  @override
  bool get enableProductReview => true;

  void getListCountries() {
    /// Get List Countries
    Services().api.getCountries()?.then(
          (countries) async {
        final storage = LocalStorage('fstore');
        try {
          // save the user Info as local storage
          final ready = await storage.ready;
          if (ready) {
            await storage.setItem(kLocalKey['countries']!, countries);
          }
        } catch (err) {
          printLog(err);
        }
      },
    );
  }

  Future<Discount?> checkValidCoupon(
      BuildContext context, String couponCode) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final discount = await Coupons.getDiscount(
      cartModel: cartModel,
      couponCode: couponCode,
    );

    if (discount?.discount != null) {
      await cartModel.updateDiscount(discount: discount);
      return discount;
    }

    return null;
  }

  @override
  Future<void> applyCoupon(context,
      {Coupons? coupons,
      String? code,
      Function? success,
      Function? error}) async {
    try {
      final discount = await checkValidCoupon(context, code!.toLowerCase());
      if (discount != null) {
        success!(discount);
        return;
      }
    } catch (err) {
      error!(err.toString());
      return;
    }
    error!(S.of(context).couponInvalid);
  }

  @override
  Future<void> doCheckout(BuildContext context,
      {Function? success, Function? error, Function? loading}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (kPaymentConfig['EnableOnePageCheckout']) {
      loading!(true);
      var params = Order().toJson(
          cartModel, userModel.user != null ? userModel.user!.id : null, true);
      params['token'] = userModel.user != null ? userModel.user!.cookie : null;

      var url = await Services().api.getCheckoutUrl(
          params, Provider.of<AppModel>(context, listen: false).langCode)!;
      // var url = 'https://bing.com';
      loading(false);

      /// Navigate to Webview payment
      String? orderSuccess;
/*      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentWebview(
                  url: url,
                  onFinish: (status) async {
                    orderSuccess = status;
                  },
                )),
      );*/
      if (orderSuccess != null) {
        cartModel.clearCart();
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuccessScreen(
                    order: Order(number: orderSuccess),
                  )),
        );
      }
      return;
    }

    /// return success to navigate to Native payment
    success!();
  }

  // Create a new order on woocomarce
  @override
  Future<Order?> createOrder(BuildContext context, // # 2
      {Function? onLoading,
      Function? success,
      Function? error,
      bool paid = false,
      bool cod = false,
      bool bacs = false,
      String transactionId = ''}) async {
    var listOrder = [];
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final storage = LocalStorage('data_order');
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      final order = await Services().api.createOrder(
          cartModel: cartModel,
          user: userModel,
          paid: paid,
          transactionId: transactionId)!;
      print('index.dart- createOrder() - order $order');

      //                 "any",
      //                 "pending",
      //                 "processing",
      //                 "on-hold",
      //                 "completed",
      //                 "cancelled",
      //                 "refunded",
      //                 "failed"

      if (bacs) {
        await Services().api.updateOrder(order.id,
            status: 'pending', // AKA ממתין לתשלום
            token: userModel.user != null ? userModel.user!.cookie : null);
      }
      if (cod && kPaymentConfig['UpdateOrderStatus']) {
        await Services().api.updateOrder(order.id,
            status: 'pending',
            token: userModel.user != null ? userModel.user!.cookie : null);
      }
      if (!isLoggedIn) {
        var items = storage.getItem('orders');
        if (items != null) {
          listOrder = items;
        }
        listOrder.add(order.toOrderJson(cartModel, null));
        await storage.setItem('orders', listOrder);
      }
      success!(order);
      return order;
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
      if (error != null) {
        error(e.toString());
      }
    }
  }

  // A function return sample
  void whatever({Function? success}){
    success!('lol');
  }
  void callWhatever(){
    whatever(
      success: (status) => print('status $status')
    );
  }

  @override
  void placeOrder(context,
      // placeOrder () -> (payment method) -> createOrder() on Woo
      {CartModel? cartModel,
      PaymentMethod? paymentMethod,
      Function? onLoading,
      Function? success,
      Function? error}) {
    Provider.of<CartModel>(context, listen: false)
        .setPaymentMethod(paymentMethod);

    print("payment method ${paymentMethod?.id}");
    if (paymentMethod!.id == 'cod') {
      /// Cash on delivery
      createOrder(context,
          cod: true, onLoading: onLoading, success: success, error: error);
      return;
    }

    if (paymentMethod.id == 'bacs') {
      /// Direct bank transfer (BACS)
      createOrder(context,
          bacs: true, onLoading: onLoading, success: success, error: error);
      return;
    }

    /// iCredit (Any time paymentMethod.id != 'cod')
    final user = Provider.of<UserModel>(context, listen: false).user;
    print("received user is ${user}");
    var params =
        Order().toJson(cartModel!, user != null ? user.id : null, true);
    params['token'] = user != null ? user.cookie : null;
    print("received params is ${params}");

    // 2. Start iCredit payment, change status to Completed on Success
    makePaymentWebView(context, params, onLoading, success, error);

  }

// If not cod or bacs:
  Future<void> makePaymentWebView(context, Map<String, dynamic> params,
      Function? onLoading, Function? webView_success, Function? error) async {
    try {
      final addressModel =
          Provider.of<CartModel>(context, listen: false).address;
      // final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
      // final order_details = provider.of<

      var url = await iCreditGetUrl(
          city: '${addressModel?.city}',
          street: '${addressModel?.street}',
          phone: '${addressModel?.phoneNumber}',
          email: '${addressModel?.email}',
          buyer_name: '${addressModel?.firstName}',
          total_price:
          Provider.of<CartModel>(context, listen: false).getTotal());

      // onLoading(true);
      // 1. Create order with status Pending AKA ממתין לתשלום
      var order = await createOrder(context,
          bacs: true, onLoading: onLoading, success:
              (Order _order){
            // webView_success;
            print('createOrder $_order');
              // order = _order;
              },
          error: error);

      // onLoading(false);
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentWebview(
                url: url,
                onFinish: (String? status) async {
                  // print('makePaymentWebView() - onFinish');
                  // print('statuss:$status');
                  if(status != null){

                    // await createOrder(context,
                    // paid: true,
                    // bacs: false, onLoading: onLoading, success: webView_success, error: error);

                    // webView_success;
                    final userModel = Provider.of<UserModel>(context, listen: false);
                    await Services().api.updateOrder('${order?.id}',
                        status: 'processing',
                        token: userModel.user != null ? userModel.user!.cookie : null);
                        // return;

                    await Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                            order: Order(number: order?.number),
                          )),
                    );

                    print('------');
                    print('placeOrder Success:');
                    print(order);

                    Provider.of<CartModel>(context, listen: false).clearCart();
                    Provider.of<CartModel>(context, listen: false).changeBillingStatus('Stop');
                    // Clear ShippingIndex & reset paymentIndex
                    Provider.of<CheckoutProviderV3>(context, listen: false).changeShippingIndex(0);
                    Provider.of<CheckoutProviderV3>(context, listen: false).changePaymentIndex(0);

                  }
                })),
      );
    } catch (e, trace) {
      error!(e.toString());
      printLog(trace.toString());
    }
  }

  @override
  Map<String, dynamic>? getPaymentUrl(context) {
    return null;
  }

  @override
  Widget renderCartPageView(
      {BuildContext? context,
      bool? isModal,
      bool? isBuyNow,
      PageController? pageController}) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        MyCart(
          controller: pageController,
          isBuyNow: isBuyNow,
          isModal: isModal,
        ),
        // ORIGINAL
        Checkout(controller: pageController, isModal: isModal), // ORIGINAL
        // MY
        // MyCheckout(controller: pageController, isModal: isModal),
      ],
    );
  }

  @override
  void updateUserInfo(
      {User? loggedInUser,
      context,
      required onError,
      onSuccess,
      required currentPassword,
      required userDisplayName,
      userEmail,
      userNiceName,
      userUrl,
      userPassword}) {
    var params = {
      'user_id': loggedInUser!.id,
      'display_name': userDisplayName,
      'user_email': userEmail,
      'user_nicename': userNiceName,
      'user_url': userUrl,
    };
    if (!loggedInUser.isSocial! && userPassword!.isNotEmpty) {
      params['user_pass'] = userPassword;
    }
    if (!loggedInUser.isSocial! && currentPassword.isNotEmpty) {
      params['current_pass'] = currentPassword;
    }
    Services().api.updateUserInfo(params, loggedInUser.cookie)!.then((value) {
      var param = value!['data'] ?? value;
      param['password'] = userPassword;
      onSuccess!(User.fromJson(param));
    }).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  Future<void> onLoadedAppConfig(String? lang, Function callback) async {
    /// Get the config from Caching
    if (kAdvanceConfig['isCaching']) {
      // if (1 == 2) {
      final configCache = await Services().api.getHomeCache(lang);
      if (configCache != null) {
        callback(configCache);
      }
    }

    /// get list countries
    getListCountries();
  }

  Widget renderVariantItem(String name, String? option) {
    return Row(
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 50.0, maxWidth: 200),
          child: Text(
            // ignore: prefer_single_quotes
            "${name[0].toUpperCase()}${name.substring(1)} ",
          ),
        ),
        name == 'color'
            ? Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: HexColor(
                        kNameToHex[option!.toLowerCase()]!,
                      ),
                    ),
                  ),
                ),
              )
            : Expanded(
                child: Text(
                  option!,
                  textAlign: TextAlign.end,
                ),
              ),
      ],
    );
  }

  @override
  Widget renderVariantCartItem(variation, Map<String, dynamic>? options) {
    var list = <Widget>[];
    if (options != null && options.isNotEmpty) {
      for (var key in options.keys) {
        list.add(renderVariantItem(key, '${options[key]}'));
        list.add(const SizedBox(
          height: 5.0,
        ));
      }
    } else {
      for (var att in variation.attributes) {
        list.add(renderVariantItem(att.name!, att.option));
        list.add(const SizedBox(
          height: 5.0,
        ));
      }
    }
    return Column(children: list);
  }

  @override
  Widget renderAddonsOptionsCartItem(
      context, List<AddonsOption>? selectedOptions) {
    if (selectedOptions?.isEmpty ?? true) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        selectedOptions!
            .map((e) => e.isFileUploadType ? e.label!.split('/').last : e.label)
            .join(', '),
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  void loadShippingMethods(context, CartModel cartModel, bool beforehand) {
//    if (!beforehand) return;
//    final cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      final token = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user!.cookie
          : null;
      Provider.of<ShippingMethodModel>(context, listen: false)
          .getShippingMethods(cartModel: cartModel, token: token);
    });
  }

  @override
  Widget renderButtons(
      BuildContext context, Order order, cancelOrder, createRefund) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: cancelOrder,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (order.status!.isCancelled)
                        ? Colors.blueGrey
                        : Colors.red),
                child: Text(
                  S.of(context).cancel.toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: createRefund,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: order.status == OrderStatus.refunded
                        ? Colors.blueGrey
                        : Colors.lightBlue),
                child: Text(
                  S.of(context).refunds.toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  String? getPriceItemInCart(Product product, ProductVariation? variation,
      Map<String, dynamic> currencyRate, String? currency,
      {List<AddonsOption>? selectedOptions}) {
    if ((selectedOptions?.isNotEmpty ?? false)) {
      return PriceTools.getAddsOnPriceProductValue(
          product, selectedOptions!, currencyRate, currency,
          onSale: true);
    }
    return variation != null && variation.id != null
        ? PriceTools.getVariantPriceProductValue(
            variation, currencyRate, currency, onSale: true)
        : PriceTools.getPriceProduct(product, currencyRate, currency,
            onSale: true);
  }

  @override
  Future<List<Country>?> loadCountries(BuildContext context) async {
    final storage = LocalStorage('fstore');
    List<Country>? countries = <Country>[];
    if (DefaultCountry.isNotEmpty) {
      for (var item in DefaultCountry) {
        countries.add(Country.fromConfig(
            item['iosCode'], item['name'], item['icon'], []));
      }
    } else {
      try {
        // save the user Info as local storage
        final ready = await storage.ready;
        if (ready) {
          final items = await storage.getItem(kLocalKey['countries']!);
          countries = ListCountry.fromOpencartJson(items).list;
        }
      } catch (err) {
        printLog(err);
      }
    }
    return countries;
  }

  @override
  Future<List<CountryState>> loadStates(Country country) async {
    final items = await Tools.loadStatesByCountry(country.id!);
    var states = <CountryState>[];
    if (items.isNotEmpty) {
      for (var item in items) {
        states.add(CountryState.fromConfig(item));
      }
    } else {
      try {
        final items = await Services().api.getStatesByCountryId(country.id);
        if (items != null && items.isNotEmpty) {
          for (var item in items) {
            states.add(CountryState.fromWooJson(item));
          }
        }
      } catch (e) {
        printLog(e.toString());
      }
    }
    return states;
  }

  @override
  Future<void> resetPassword(BuildContext context, String username) async {
    try {
      final val = await (Provider.of<UserModel>(context, listen: false)
          .submitForgotPassword(
              forgotPwLink: '',
              data: {'user_login': username}) as Future<String>);
      if (val.isEmpty) {
        Tools.showSnackBar(
            Scaffold.of(context), S.of(context).checkConfirmLink);
        Future.delayed(
            const Duration(seconds: 1), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(Scaffold.of(context), val);
      }
      return;
    } catch (e) {
      printLog('Unknown Error: $e');
    }
  }

  @override
  Future<void> syncCartFromWebsite(
      String? token, CartModel cartModel, BuildContext context) async {
    try {
      var items =
          await (Services().api.getCartInfo(token) as Future<List<dynamic>?>);
      if (items != null && items.isNotEmpty) {
        cartModel.clearCart();
        List<Map<String, dynamic>>.from(items).forEach((item) {
          cartModel.addProductToCart(
              context: context,
              product: Product.fromJson(item['product']),
              quantity: item['quantity'],
              variation: item['variation'] != null
                  ? ProductVariation.fromJson(item['variation'])
                  : null);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void>? syncCartToWebsite(CartModel cartModel) {
    if (kAdvanceConfig['EnableSyncCartToWebsite'] == true) {
      return Services().api.syncCartToWebsite(cartModel, cartModel.user);
    }
    return null;
  }

  @override
  Widget renderTaxes(TaxModel taxModel, BuildContext context) {
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<CartModel>(context, listen: false).currency;

    if (taxModel.taxes != null && taxModel.taxes!.isNotEmpty) {
      var list = <Widget>[];
      taxModel.taxes!.forEach((element) {
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              element.title!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).accentColor,
              ),
            ),
            Text(
              PriceTools.getCurrencyFormatted(element.amount, currencyRate,
                  currency: currency)!,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            )
          ],
        ));
      });

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          children: list,
        ),
      );
    } else if (taxModel.taxesTotal > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              S.of(context).tax,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).accentColor,
              ),
            ),
            Text(
              PriceTools.getCurrencyFormatted(taxModel.taxesTotal, currencyRate,
                  currency: currency)!,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Future<Product?>? getProductDetail(BuildContext context, Product? product) {
    return Services().api.getProduct(product!.id);
  }
}
