import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/utils/logs.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/tools/flash.dart';
import '../../../generated/l10n.dart' show S;
import '../../../models/index.dart'
    show
        AddonsOption,
        AppModel,
        Product,
        ProductAttribute,
        ProductModel,
        ProductVariation;
import '../../../services/index.dart';
import '../../../widgets/common/webview.dart';

class ProductVariant extends StatefulWidget {
  final Product? product;
  final Function? onSelectVariantImage;

  ProductVariant(
    this.product, {
    this.onSelectVariantImage,
  });

  @override
  _StateProductVariant createState() => _StateProductVariant(product!);
}

class _StateProductVariant extends State<ProductVariant> {
  Product product;

  ProductVariation? productVariation;

  Map<String, Map<String, AddonsOption>> selectedOptions = {};
  List<AddonsOption> addonsOptions = [];

  _StateProductVariant(this.product);

  final services = Services();
  Map<String?, String?>? mapAttribute = {};
  late List<ProductVariation>? variations = [];

  int quantity = 1;

  void updateSelectedOptions(
      Map<String, Map<String, AddonsOption>> selectedOptions) {
    this.selectedOptions = selectedOptions;
    final options = <AddonsOption>[];
    for (var addOns in selectedOptions.values) {
      options.addAll(addOns.values);
    }
    product.selectedOptions = options;
  }

  /// Get product variants
  Future<void> getProductVariations() async {
    await services.widget.getProductVariations(
        context: context,
        product: product,
        onLoad: ({
          Product? productInfo,
          List<ProductVariation>? variations,
          Map<String?, String?>? mapAttribute,
          ProductVariation? variation,
        }) {

          print('vvariations: $variations');
          print('mapAttributeLoaded: $mapAttribute');

          setState(() {
            if (productInfo != null) {
              product = productInfo;
            }
            this.variations = variations;
            this.mapAttribute = mapAttribute;
            if (variation != null) {
              productVariation = variation;
              Provider.of<ProductModel>(context, listen: false)
                  .changeProductVariation(productVariation);
            }
          });
          return;
        });

    // printLog('productVariation.length 2');
    // printLog(productVariation!.attributes);
    // printLog(productVariation!.price);
  }

  Future<void> getProductAddons() async {
    await services.widget.getProductAddons(
      context: context,
      product: product,
      selectedOptions: selectedOptions,
      onLoad: (
          {Product? productInfo,
          required Map<String, Map<String, AddonsOption>> selectedOptions}) {
        if (productInfo != null) {
          product = productInfo;
        }
        updateSelectedOptions(selectedOptions);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getProductVariations();
    getProductAddons();
  }

  @override
  void dispose() {
    FlashHelper.dispose();
    super.dispose();
  }

  /// Support Affiliate product
  void openWebView() {
    if (product.affiliateUrl == null || product.affiliateUrl!.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            brightness: Theme.of(context).brightness,
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
                )));
  }

  /// Add to Cart & Buy Now function
  void addToCart([bool buyNow = false, bool inStock = false]) {
    // productVariation?.sku ==

    print('addToCart - buyNow $buyNow');
    print('addToCart - inStock $inStock');
    print('addToCart - quantity $quantity');
    print('addToCart - productVariation.toJson ${productVariation?.toJson()}');
    print('addToCart - product $product');
    services.widget.addToCart(context, product, quantity, productVariation,
        mapAttribute!, buyNow, inStock);
  }

  /// check limit select quality by maximum available stock
  int getMaxQuantity() {
    var limitSelectQuantity = kCartDetail['maxAllowQuantity'] ?? 100;
    if (productVariation != null) {
      if (productVariation!.stockQuantity != null) {
        limitSelectQuantity = math.min<int>(
            productVariation!.stockQuantity!, kCartDetail['maxAllowQuantity']);
      }
    } else if (product.stockQuantity != null) {
      limitSelectQuantity = math.min<int>(
          product.stockQuantity!, kCartDetail['maxAllowQuantity']);
    }
    return limitSelectQuantity;
  }

  /// Check The product is valid for purchase
  bool couldBePurchased() {
    return services.widget
        .couldBePurchased(variations, productVariation, product, mapAttribute);
  }

  void onSelectProductVariant({
    ProductAttribute? attr,
    String? val,
    List<ProductVariation>? variations,
    Map<String?, String?>? mapAttribute,
    Function? onFinish,
  }) {
    print('onSelectProductVariant, MapAttribute: $mapAttribute');
    print('onSelectProductVariant, attr: ${attr?.slug}');
    print('onSelectProductVariant, val: $val');

    services.widget.onSelectProductVariant(
      attr: attr!,
      val: val,
      variations: variations!,
      mapAttribute: mapAttribute!,
      onFinish:
          (Map<String?, String?> mapAttribute, ProductVariation? variation) {
        setState(() {
          this.mapAttribute = mapAttribute;
        });
        productVariation = variation;
        Provider.of<ProductModel>(context, listen: false)
            .changeProductVariation(variation);

        /// Show selected product variation image in gallery.
        final attrType = ProductVariantLayout[attr.cleanSlug ?? attr.name] ??
            ProductVariantLayout[attr.name!.toLowerCase()] ??
            'box';
        if (widget.onSelectVariantImage != null && attrType == 'image') {
          attr.options!.forEach((option) {
            if (option['name'] == val &&
                option['description'].toString().contains('http')) {
              final selectedImageUrl = option['description'];
              widget.onSelectVariantImage!(selectedImageUrl);
            }
          });
        }
      },
    );
  }

  void onSelectProductAddons({
    required Map<String, Map<String, AddonsOption>> selectedOptions,
  }) {
    setState(() {
      updateSelectedOptions(selectedOptions);
    });
  }

  List<Widget> getProductAttributeWidget() {
    final lang = Provider.of<AppModel>(context, listen: false).langCode ?? 'en';
    return services.widget.getProductAttributeWidget(
        lang, product, mapAttribute!, onSelectProductVariant, variations!);
  }

  List<Widget> getProductAddonsWidget() {
    final lang = Provider.of<AppModel>(context, listen: false).langCode ?? 'en';
    return services.widget.getProductAddonsWidget(
      context: context,
      selectedOptions: selectedOptions,
      lang: lang,
      product: product,
      onSelectProductAddons: onSelectProductAddons,
      quantity: quantity,
    );
  }

  List<Widget> getBuyButtonWidget() {
    return services.widget.getBuyButtonWidget(context, productVariation,
        product, mapAttribute, getMaxQuantity(), quantity, addToCart, (val) {
      setState(() {
        quantity = val;
      });
    }, variations);
  }

  List<Widget> getProductTitleWidget() {
    return services.widget
        .getProductTitleWidget(context, productVariation, product);
  }

  @override
  Widget build(BuildContext context) {
    FlashHelper.init(context);
    final isVariationLoading =
        productVariation == null && (variations?.isEmpty ?? true);

    return Column(
      children: <Widget>[
        ...getProductTitleWidget(),
        if (!isVariationLoading) ...getProductAttributeWidget(),
        ...getProductAddonsWidget(),
        ...getBuyButtonWidget(),
      ],
    );
  }
}
