import 'package:collection/collection.dart' show IterableExtension;
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' as html;
import 'package:fstore/screens/users/spider_point_screen.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../common/config.dart';
import '../common/constants.dart';
import '../generated/l10n.dart';
import '../models/index.dart'
    show CartModel, Product, ProductModel, ProductVariation;
import '../screens/cart/cart_screen.dart';
import '../widgets/common/webview.dart';
import '../widgets/product/product_variant.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:fstore/screens/users/spider_point_screen.dart';
import 'package:inspireui/widgets/flux_image.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, User, UserModel, WishListModel;
import '../../models/notification_model.dart';
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/common/webview.dart';
import 'dart:convert' as convert;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// Product_varinat_mixing.dart - fluxStore-spider3d

mixin ProductVariantMixin {
  ProductVariation? updateVariation(
    List<ProductVariation> variations,
    Map<String?, String?> mapAttribute,
  ) {
    final templateVariation =
        variations.isNotEmpty ? variations.first.attributes : null;
    final listAttributes = variations.map((e) => e.attributes);

    ProductVariation productVariation;
    var attributeString = '';

    /// Flat attribute
    /// Example attribute = { "color": "RED", "SIZE" : "S", "Height": "Short" }
    /// => "colorRedsizeSHeightShort"
    templateVariation?.forEach((element) {
      final key = element.name;
      final value = mapAttribute[key];
      attributeString += value != null ? '$key$value' : '';
    });

    /// Find attributeS contain attribute selected
    final validAttribute = listAttributes.lastWhereOrNull(
      (attributes) =>
          attributes.map((e) => e.toString()).join().contains(attributeString),
    );

    if (validAttribute == null) return null;

    /// Find ProductVariation contain attribute selected
    /// Compare address because use reference
    productVariation =
        variations.lastWhere((element) => element.attributes == validAttribute);

    productVariation.attributes.forEach((element) {
      if (!mapAttribute.containsKey(element.name)) {
        mapAttribute[element.name!] = element.option!;
      }
    });
    return productVariation;
  }

  bool isPurchased(
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?> mapAttribute,
    bool isAvailable,
  ) {
    var inStock;
    // ignore: unnecessary_null_comparison
    if (productVariation != null) {
      inStock = productVariation.inStock!;
    } else {
      inStock = product.inStock!;
    }

    var isValidAttribute = false;
    try {
      // My Map to make those List equals (Bug fix on the App)
      product.attributes!.map((e) {
        print(e.name);
        mapAttribute.removeWhere((key, value) => key != e.name);
      });
      // print(mapAttribute.length);
      // print(product.attributes!.length);

      if (product.attributes!.length == mapAttribute.length &&
          (product.attributes!.length == mapAttribute.length ||
              product.type != 'variable')) {
        isValidAttribute = true;
      }
    } catch (_) {}

    print('isPurchased - inStock - $inStock - VariationTest');
    print('isPurchased - isValidAttribute - $isValidAttribute - VariationTest');
    print('isPurchased - isAvailable - $isAvailable - VariationTest');
    return inStock && isAvailable
        // && isValidAttribute
        /// My Commented to fix some variables products unAvailable to buy
        /// Product example: "MK8 3d printer nozzle" (or mk10 43USD)
        ;
  }

  List<Widget> makeProductTitleWidget(BuildContext context,
      ProductVariation? productVariation, Product product, bool isAvailable) {
    var listWidget = <Widget>[];

    // ignore: unnecessary_null_comparison
    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;

    var stockQuantity =
        (kProductDetail.showStockQuantity) && product.stockQuantity != null
            ? '  (${product.stockQuantity}) '
            : '';
    if (Provider.of<ProductModel>(context, listen: false).productVariation !=
        null) {
      stockQuantity = (kProductDetail.showStockQuantity) &&
              Provider.of<ProductModel>(context, listen: false)
                      .productVariation!
                      .stockQuantity !=
                  null
          ? '  (${Provider.of<ProductModel>(context, listen: false).productVariation!.stockQuantity}) '
          : '';
    }

    var showSpiders = true;
    for (var cat in product.categories) {
      if (cat.id == '2341') {
        // 2341 is the ID of the 3d Printers Category
        showSpiders = false;
        // break;
      }
      // print("showSpiders");
      // print(showSpiders);
      // print("cat.id");
      // print(cat.id);
    }

    if (isAvailable) {
      listWidget.add(
        const SizedBox(height: 5.0),
      );

/*      listWidget.add(widget(
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                contentPadding: const EdgeInsets.only(top: 30, bottom: 10),
                insetPadding: const EdgeInsets.all(0),
                content: SingleChildScrollView(
                  child: SpidersPointScreen(
                    isFullPage: false,
                  ),
                ),
                actions: [
                  TextButton(
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(3),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[100])),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'חזור',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SpidersPointScreen(),
            //   ),
            // );
          },
          child: Row(
            children: <Widget>[
              if (kProductDetail.showSku && showSpiders == true) ...[
                Text(
                  // '${S.of(context).sku}: ',
                  'על מוצר זה תרוויח: ',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                const SizedBox(
                  width: 3,
                ),
                Image.asset('assets/images/spider_coin.png',
                    // color: kGrey600, height: 24, width: 24));
                    color: Theme.of(context).primaryColor,
                    // color: Theme.of(context).accentColor,
                    height: 22,
                    width: 22),
                const SizedBox(
                  width: 3,
                ),
                Text(
                  // product.sku!,
                  (double.parse(product.price!) / 10)
                          .toString()
                          .replaceAll('.', '') +
                      ' ספיידרס',
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(
                  width: 3,
                ),
                Text(
                    // product.sku!,
                    '(' +
                        '₪' +
                        (double.parse(product.price!) / 10)
                            .toString()
                            .replaceAll('.00', '')
                            .replaceAll('.0', '')
                        // .replaceAll('.', '')
                        +
                        ')',
                    style: Theme.of(context).textTheme.subtitle2
                    //| !.copyWith(
                    //       color: Theme.of(context).primaryColor,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    ),
              ],
            ],
          ),
        ),
      ));*/

      listWidget.add(
        const SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            if (kAdvanceConfig['showStockStatus']) ...[
              Text(
                '${S.of(context).availability}: ',
                // '${product.categories}: ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              // ignore: unnecessary_null_comparison
              product.backOrdered != null && product.backOrdered
                  ? Text(
                      '${S.of(context).backOrder}',
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: const Color(0xFFEAA601),
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : Text(
                      inStock
                          ? '${S.of(context).inStock}$stockQuantity'
                          : S.of(context).outOfStock,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            // color: inStock ? Theme.of(context).primaryColor : const Color(0xFFe74c3c),
                            color: inStock ? kColorInStock : kColorOutOfStock,
                            fontWeight: FontWeight.w600,
                          ),
                    )
            ],
          ],
        ),
      );

      if (product.shortDescription != null &&
          product.shortDescription!.isNotEmpty) {
        listWidget.add(
          Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: html.HtmlWidget(
              product.shortDescription!,
            ),
          ),
        );
      }

      listWidget.add(
        const SizedBox(height: 15.0),
      );
    }

    return listWidget;
  }

  List<Widget> makeBuyButtonWidget(
    BuildContext context,
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?>? mapAttribute,
    int maxQuantity,
    int quantity,
    Function addToCart,
    Function onChangeQuantity,
    bool isAvailable,
  ) {
    final theme = Theme.of(context);

    // ignore: unnecessary_null_comparison
    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;
    final isExternal = product.type == 'external' ? true : false;
    final isVariationLoading =
        // ignore: unnecessary_null_comparison
        product.type == 'variable' &&
            productVariation == null &&
            (mapAttribute?.isEmpty ?? true);

    final buyOrOutOfStockButton = Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isExternal
            ? (inStock &&
                    (product.attributes!.length == mapAttribute!.length) &&
                    isAvailable)
                ? theme.primaryColor
                : theme.disabledColor
            : theme.primaryColor,
      ),
      child: Center(
        child: Text(
          (((inStock && isAvailable) || isExternal)
              ? S.of(context).buyNow
              : (isAvailable
                      ? S.of(context).outOfStock
                      : isVariationLoading
                          ? S.of(context).loading
                          : S.of(context).unavailable)
                  .toUpperCase()),
          style: Theme.of(context).textTheme.button!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );

    if (!inStock && !isExternal && !product.backOrdered) {
      return [
        buyOrOutOfStockButton,
      ];
    }

    if ((product.isPurchased) && (product.isDownloadable ?? false)) {
      return [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async => await Share.share(product.files![0]!),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                      child: Text(
                    S.of(context).download,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Colors.white,
                        ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ];
    }

    return [
      if (!isExternal && (kProductDetail.showStockQuantity)) ...[
        const SizedBox(width: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                S.of(context).selectTheQuantity + ':',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Expanded(
              child: Container(
                height: 32.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: QuantitySelection(
                  expanded: true,
                  value: quantity,
                  color: theme.accentColor,
                  limitSelectQuantity: maxQuantity,
                  onChanged: onChangeQuantity,
                ),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 10),
      Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                print(
                    'buyOrOutOfStockButton - isAvailable - $isAvailable - VariationTest');
                addToCart(true, inStock);
              },
              child: buyOrOutOfStockButton,
            ),
          ),
          const SizedBox(width: 10),
          if (isAvailable && inStock && !isExternal)
            Expanded(
              child: GestureDetector(
                onTap: () => addToCart(false, inStock),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: Center(
                    child: Text(
                      S.of(context).addToCart.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      )
    ];
  }

  /// Add to Cart & Buy Now function
  void addToCart(BuildContext context, Product product, int quantity,
      ProductVariation? productVariation, Map<String?, String?> mapAttribute,
      [bool buyNow = false, bool inStock = false]) {
    /// Out of stock || Variable product but not select any variant.
    if (!inStock || (product.type == 'variable' && mapAttribute.isEmpty)) {
      return;
    }

    final cartModel = Provider.of<CartModel>(context, listen: false);
    if (product.type == 'external') {
      openWebView(context, product);
      return;
    }

    print('mapAttr: ${mapAttribute.keys.toList()}');
    var cleanedAttrMap = Map<String?,String?>.from(mapAttribute);
    cleanedAttrMap.removeWhere((key, value) => value == null);
    cleanedAttrMap =  cleanedAttrMap.map((key, value) => MapEntry(key?.replaceAll(' ', ''), value));
    print('cleanedAttrMap: ${cleanedAttrMap}');

    final _mapAttribute = Map<String, String>.from(cleanedAttrMap);
    productVariation =
        Provider.of<ProductModel>(context, listen: false).productVariation;
    var message = cartModel.addProductToCart(
        context: context,
        product: product,
        quantity: quantity,
        variation: productVariation,
        options: _mapAttribute);

    if (message.isNotEmpty) {
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).errorColor,
            controller: controller,
            style: FlashStyle.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              message: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
    } else {
      if (buyNow) {
        Navigator.of(context).pushNamed(
          RouteList.cart,
          arguments: CartScreenArgument(isModal: true, isBuyNow: true),
        );
      }
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).primaryColor,
            controller: controller,
            style: FlashStyle.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              title: Text(
                product.name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              message: Text(
                S.of(context).addToCartSucessfully,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          );
        },
      );
    }
  }

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
}
