import 'package:flutter/foundation.dart';

import '../../../common/tools.dart';
import '../../index.dart';


mixin CartMixin on ChangeNotifier {
// mixin CartMixin { // original
  User? user;
  double taxesTotal = 0;
  List<Tax> taxes = [];
  double rewardTotal = 0;


  PaymentMethod? paymentMethod;

  String? notes;
  String? currency;
  Map<String, dynamic>? currencyRates;

  String? myBillingStatus;
  void changeBillingStatus(String value){
    // print(myBillingStatus);
    myBillingStatus = '$value';
    // print(myBillingStatus);
    notifyListeners();
  }

  final Map<String?, Product?> item = {};

  final Map<String, ProductVariation?> productVariationInCart = {};

  final Map<String, List<AddonsOption>?> productAddonsOptionsInCart = {};

  // The IDs and quantities of products currently in the cart.
  final Map<String, int?> productsInCart = {};

  // The IDs and meta_data of products currently in the cart for woo commerce
  final Map<String, dynamic> productsMetaDataInCart = {};

  int get totalCartQuantity => productsInCart.values.fold(0, (v, e) => v + e!);

  bool _hasProductVariation(String id) =>
      productVariationInCart[id] != null &&
      productVariationInCart[id]!.price != null &&
      productVariationInCart[id]!.price!.isNotEmpty;

  double getProductPrice(id) {
    if (_hasProductVariation(id)) {
      return double.parse(productVariationInCart[id]!.price!) *
          productsInCart[id]!;
    } else {
      var productId = Product.cleanProductID(id);

      var price = PriceTools.getPriceProductValue(item[productId], currency,
          onSale: true);
      if ((price?.isNotEmpty ?? false) && productsInCart[id] != null) {
        return double.parse(price!) * productsInCart[id]!;
      }
      return 0.0;
    }
  }

  double getProductAddonsPrice(String id) {
    if (productAddonsOptionsInCart.isNotEmpty) {
      var price = 0.0;
      if (productAddonsOptionsInCart[id] == null) {
        return 0.0;
      }
      for (var option in productAddonsOptionsInCart[id]!) {
        var quantity = productsInCart[id] ?? 0;
        var optionPrice = (double.tryParse(option.price ?? '0.0') ?? 0.0);
        if (option.isQuantityBased) {
          optionPrice *= quantity;
        }
        price += optionPrice;
      }
      return price;
    }
    return 0.0;
  }

  double? getSubTotal() {
    return productsInCart.keys.fold(0.0, (sum, id) {
      return sum! + getProductPrice(id) + getProductAddonsPrice(id);
    });
  }

  void setPaymentMethod(data) {
    // print('X ${paymentMethod?.id}');
    paymentMethod = data;
    // print('2X ${paymentMethod?.id}');
    notifyListeners(); // my
    // print('3X ${paymentMethod?.id}');
  }

  // Returns the Product instance matching the provided id.
  Product? getProductById(String id) {
    return item[id];
  }

  // Returns the Product instance matching the provided id.
  ProductVariation? getProductVariationById(String key) {
    return productVariationInCart[key];
  }

  String? getCheckoutId() {
    return '';
  }

  // My (Based saveShippingAddress() )
/*  Future<void> saveUserDetails(Address? address) async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['shippingAddress']!, address);
      }
    } catch (_) {}
  }*/

  void setUser(data) {
    user = data;
  }



  void loadSavedCoupon() {}
}
