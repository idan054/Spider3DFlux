import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show CartModel, Order;
import '../../services/index.dart';
import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../generated/l10n.dart';
import '../models/entities/order.dart';
import '../models/index.dart'
    show
        AddonsOption,
        AfterShip,
        AppModel,
        CartModel,
        Country,
        CountryState,
        Coupons,
        OrderNote,
        PaymentMethod,
        Product,
        ProductAttribute,
        ProductVariation,
        TaxModel,
        User,
        UserModel;
import '../screens/index.dart';
import '../services/index.dart';
import '../widgets/common/webview.dart';
import '../widgets/orders/tracking.dart';
import '../widgets/product/product_card_view.dart';

abstract class BaseFrameworks {
  bool get enableProductReview;

  Future<void> doCheckout(
    BuildContext context, {
    Function? success,
    Function? error,
    Function? loading,
  });

  Future<void> applyCoupon(
    BuildContext context, {
    Coupons? coupons,
    String? code,
    Function? success,
    Function? error,
  });

  Future<void>? removeCoupon(BuildContext context) => null;

  Future<void> createOrder(BuildContext context,
      {Function? onLoading,
      Function? success,
      Function? error,
      bool paid = false,
      bool cod = false,
      bool bacs = false,
      String transactionId = ''});

  void placeOrder( // original
    BuildContext context, {
    CartModel? cartModel,
    PaymentMethod? paymentMethod,
    Function? onLoading,
    Function? success,
    Function? error,
  });

  Map<dynamic, dynamic>? getPaymentUrl(context);

  /// For Cart Screen
  Widget renderCartPageView({
    BuildContext? context,
    bool? isModal,
    bool? isBuyNow,
    PageController? pageController,
  });

  Widget renderVariantCartItem(
    ProductVariation variation,
    Map<String, dynamic>? options,
  );

  String? getPriceItemInCart(
    Product product,
    ProductVariation? variation,
    Map<String, dynamic> currencyRate,
    String? currency, {
    List<AddonsOption>? selectedOptions,
  });

  /// For Update User Screen
  void updateUserInfo({
    User? loggedInUser,
    BuildContext? context,
    required Function onError,
    Function? onSuccess,
    required String currentPassword,
    required String userDisplayName,
    String? userEmail,
    String? userNiceName,
    String? userUrl,
    String? userPassword,
  });

  Widget renderCurrentPassInputforEditProfile({
    BuildContext? context,
    TextEditingController? currentPasswordController,
  }) =>
      const SizedBox();

  /// For app model
  Future<void>? onLoadedAppConfig(String? lang, Function callback) => null;

  /// For Shipping Address checkout
  void loadShippingMethods(
    BuildContext context,
    CartModel cartModel,
    bool beforehand,
  );

  Widget renderButtons(
    BuildContext context,
    Order order,
    cancelOrder,
    createRefund,
  ) =>
      const SizedBox();

  /// For product variant
  Future<void> getProductVariations({
    BuildContext? context,
    Product? product,
    void Function({
      Product? productInfo,
      List<ProductVariation>? variations,
      Map<String?, String?> mapAttribute,
      ProductVariation? variation,
    })?
        onLoad,
  });

  Future<void> getProductAddons({
    required BuildContext context,
    required Product product,
    required Function(
            {Product? productInfo,
            required Map<String, Map<String, AddonsOption>> selectedOptions})
        onLoad,
    required Map<String, Map<String, AddonsOption>> selectedOptions,
  }) async {
    return null;
  }

  bool couldBePurchased(
    List<ProductVariation>? variations,
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?>? mapAttribute,
  );

  void onSelectProductVariant({
    required ProductAttribute attr,
    String? val,
    required List<ProductVariation> variations,
    required Map<String?, String?> mapAttribute,
    required Function onFinish,
  });

  List<Widget> getProductAttributeWidget(
    String lang,
    Product product,
    Map<String?, String?>? mapAttribute,
    Function onSelectProductVariant,
    List<ProductVariation> variations,
  );

  List<Widget> getProductAddonsWidget({
    required BuildContext context,
    String? lang,
    required Product product,
    required Map<String, Map<String, AddonsOption>> selectedOptions,
    Function? onSelectProductAddons,
    int quantity = 1,
  }) {
    return const [SizedBox()];
  }

  List<Widget> getProductTitleWidget(
    BuildContext context,
    ProductVariation? productVariation,
    Product product,
  );

  List<Widget> getBuyButtonWidget(
    BuildContext context,
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?>? mapAttribute,
    int maxQuantity,
    int quantity,
    Function addToCart,
    Function onChangeQuantity,
    List<ProductVariation>? variations,
  );

  void addToCart(BuildContext context, Product product, int quantity,
      ProductVariation? productVariation, Map<String?, String?> mapAttribute,
      [bool buyNow = false, bool inStock = false]);

  /// Load countries for shipping address
  Future<List<Country>?> loadCountries(BuildContext context);

  /// Load states for shipping address
  Future<List<CountryState>> loadStates(Country country);

  Future<void>? resetPassword(BuildContext context, String username) => null;

  Widget renderShippingPaymentTitle(BuildContext context, String title) {
    return Text(
      // '${Theme.of(context).appBarTheme.backgroundColor.toString()}',
      title,
      // style: TextStyle(fontSize: 14, color: Theme.of(context).accentColor),
      style: TextStyle(
          fontSize: 14, color: Theme.of(context).appBarTheme.backgroundColor),
    );
  }

  Future<Product?>? getProductDetail(
    BuildContext context,
    Product? product,
  ) async =>
      product;

//Sync cart from website
  Future<void>? syncCartFromWebsite(
          String? token, CartModel cartModel, BuildContext context) =>
      null;

//Sync cart to website
  Future<void>? syncCartToWebsite(CartModel cartModel) => null;

  Widget renderTaxes(TaxModel taxModel, BuildContext context) =>
      const SizedBox();

  /// For Vendor
  Product updateProductObject(Product product, Map? json) => product;

  void OnFinishOrder(
    BuildContext context,
    Function onSuccess,
    Order order,
  ) {
    onSuccess();
  }

  /// render vendor default on product detail screen
  Widget renderVendorInfo(Product? product) => const SizedBox();

  /// vendor menu order from vendor on Setting page
  Widget renderVendorOrder(BuildContext context) => const SizedBox();

  /// feature vendor on home screen
  Widget renderFeatureVendor(config) => const SizedBox();

  ///render shipping methods screen when checkout
  Widget renderShippingMethods(
    BuildContext context, {
    Function? onBack,
    Function? onNext,
  }) {
    return ShippingMethods(onBack: onBack, onNext: onNext);
  }

  /// render screen for Category Vendor
  Widget renderVendorCategoriesScreen(data) => const SizedBox();

  /// render screen for Map
  Widget renderMapScreen() => const SizedBox();

  ///render shipping method info in review screen
  Widget renderShippingMethodInfo(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final model = Provider.of<CartModel>(context);
    // final shippingMethod = Provider.of<CartModel>(context).shippingMethod;
    // const model = null;

    return kPaymentConfig['EnableShipping'] && model.shippingMethod != null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Services().widget.renderShippingPaymentTitle(
                      context, '${model.shippingMethod!.title}'),
                ),
                Text(
                  PriceTools.getCurrencyFormatted(
                      model.getShippingCost(), currencyRate,
                      currency: model.currency)!,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).accentColor,
                      ),
                )
              ],
            ),
          )
        : Container(
            // height: 30,
            // color: Colors.green.shade700,
            );

    // Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: <Widget>[
    //         Expanded(
    //           child: Text(
    //             'בחר שיטת משלוח',
    //             style: TextStyle(
    //                 fontSize: 16, color: Theme.of(context).accentColor),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
  }

  ///render reward info in review screen
  Widget renderRewardInfo(BuildContext context) {
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final rewardTotal =
        Provider.of<CartModel>(context, listen: false).rewardTotal;

    if (rewardTotal > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              S.of(context).cartDiscount,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).accentColor,
              ),
            ),
            Text(
              PriceTools.getCurrencyFormatted(rewardTotal, currencyRate,
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
    }
    return Container();
  }

  /// render Search Screen
  Widget renderSearchScreen(context, {showChat}) {
    return SearchScreen(
      key: const Key('search'),
      showChat: showChat,
    );
  }

  /// get country name
  Future<String?> getCountryName(context, countryCode) async {
    return CountryPickerUtils.getCountryByIsoCode(countryCode).name;
  }

  /// get admin vendor url
  Widget? getAdminVendorScreen(context, dynamic user) {
    return null;
  }

  ///render timeline tracking on order detail screen
  Widget renderOrderTimelineTracking(BuildContext context, Order order) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            S.of(context).status,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.center,
          child: TimelineTracking(
            axisTimeLine: kIsWeb ? Axis.horizontal : Axis.vertical,
            status: order.status!.content,
            createdAt: order.createdAt,
            dateModified: order.dateModified,
          ),
        ),
      ],
    );
  }

  ///----- For FluxStore Listing -----///
  /// render Booking History
  Widget renderBookingHistory(context) => const SizedBox();

  /// render Add new Listing screen
  Widget renderNewListing(context) => const SizedBox();

  /// render the Product or Listing Detail screen
  Widget renderDetailScreen(BuildContext context, Product product,
      String layoutType, bool isLoading) {
    switch (layoutType) {
      case 'halfSizeImageType':
        return HalfSizeLayout(product: product, isLoading: isLoading);
      case 'fullSizeImageType':
        return FullSizeLayout(product: product, isLoading: isLoading);
      default:
        return SimpleLayout(product: product, isLoading: isLoading);
    }
  }

  /// render product card view widget
  Widget renderProductCardView({
    Product? item,
    double? width,
    double? maxWidth,
    double? height,
    bool showCart = false,
    bool showHeart = false,
    bool showProgressBar = false,
    double? marginRight,
    double? ratioProductImage = 1.2,
  }) {
    if (item == null) {
      return const SizedBox();
    }
    return ProductCard(
      item: item,
      width: width,
      maxWidth: maxWidth,
      height: height, // ?? 50 * 1.5, // My multiplication
      showCart: showCart,
      showHeart: showHeart,
      showProgressBar: showProgressBar,
      marginRight: marginRight,
      ratioProductImage: ratioProductImage,
    );
  }

  /// render vendor dashboard
  Widget renderVendorDashBoard() => const SizedBox();

  /// render vendor dashboard
  Widget renderAddonsOptionsCartItem(
    context,
    List<AddonsOption>? selectedOptions,
  ) {
    return const SizedBox();
  }

  /// render Vendor from config banner
  Widget renderVendorScreen(String? storeID) => const SizedBox();

  /// Support Affiliate product
  void openWebView(BuildContext context, Product product) {
    if (product.affiliateUrl == null || product.affiliateUrl!.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: Center(
            child: Text(S.of(context).notFound),
          ),
        );
      }));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebView(
          url: product.affiliateUrl,
          title: product.name,
        ),
      ),
    );
  }

  Future<Null>? getHomeCache(String lang) => null;

  Future<Null> createReview({
    String? productId,
    Map<String, dynamic>? data,
  }) async {}

  Future<AfterShip?> getAllTracking() async => null;

  Future<List<OrderNote>?> getOrderNote({
    UserModel? userModel,
    dynamic orderId,
  }) async =>
      null;

  /// For booking feature
  Future<Map<String, dynamic>>? getCurrencyRate() => null;

  Future<bool>? createBooking(dynamic bookingInfo) => null;

  Future<List<dynamic>>? getListStaff(String idProduct) => null;

  Future<List<String>>? getSlotBooking(
    String idProduct,
    String idStaff,
    String date,
  ) =>
      null;

  Widget renderOptionsCartItem(Product product, Map<String, dynamic>? options) {
    return const SizedBox();
  }
}
