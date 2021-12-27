import 'package:flutter/material.dart';
import 'package:inspireui/utils/logs.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../models/index.dart'
    show AppModel, Product, ProductAttribute, ProductVariation;
import '../../services/index.dart';
import '../../widgets/product/product_variant.dart';
import '../product_variant_mixin.dart';

mixin WooVariantMixin on ProductVariantMixin {
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
  }) async {
    print('product!.attributes!.isEmpty ${product!}');
    if (product.attributes!.isEmpty) {
      return;
    }


    var mapAttribute = <String?, String?>{};
    var variations = <ProductVariation>[];
    Product? productInfo;
    ProductVariation? variation;

    final lang = Provider.of<AppModel>(context!, listen: false).langCode;
    await Services()
        .api
        .getProductVariations(product, lang: lang)!
        .then((value) {
      variations = value!.toList();
    });

    if (variations.isEmpty) {
      for (var attr in product.attributes!) {
        mapAttribute.update(attr.name, (value) => attr.options![0]['name'],
            ifAbsent: () => attr.options![0]['name']);
      }
    } else {
      await Services().api.getProduct(product.id, lang: lang)!.then((onValue) {
        if (onValue != null) {
          productInfo = onValue;
        }
      });

      printLog('variations.length');
      printLog(variations.length);
      printLog(variations.first.price);

      if (productInfo!.defaultAttributes.isEmpty &&
          (kProductDetail.autoSelectFirstAttribute)) {
        /// Load default attributes from first variation.
        for (var variant in variations) {
          if (variant.price == product.price) {
            for (var attribute in variant.attributes) {
              for (var attr in product.attributes!) {
                if (attr.name == attribute.name) {
                  mapAttribute.update(
                      attr.name, (value) => attr.options![0]['name'],
                      ifAbsent: () => attr.options![0]['name']);
                }
              }
              mapAttribute.update(attribute.name, (value) => attribute.option,
                  ifAbsent: () => attribute.option);
            }
            break;
          }
          if (mapAttribute.isEmpty) {
            var firstItem = variations[0];
            for (var attribute in firstItem.attributes) {
              mapAttribute.update(attribute.name, (value) => value,
                  ifAbsent: () {
                return attribute.option;
              });
            }
          }
        }
      }

      if (productInfo!.defaultAttributes.isNotEmpty) {
        /// Load default attributes from Woo.
        for (var attribute in productInfo!.defaultAttributes) {
          /// Convert slug to name.
          final option = productInfo!.attributeSlugMap[attribute.option];
          mapAttribute[attribute.name] = option;
        }
      }

      /// Check default attributes
      for (var item in variations) {
        if (item.hasSameAttributes(mapAttribute)) {
          variation = item;
          break;
        }
      }

      if (variation == null) {
        /// Clear default attributes if it's invalid.
        mapAttribute.clear();
      }
    }

    onLoad!(
        productInfo: productInfo,
        variations: variations,
        variation: variation,
        mapAttribute: mapAttribute);
    return;
  }

  // ------
  bool couldBePurchased(
    List<ProductVariation>? variations,
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?>? mapAttribute,
  ) {
    final isAvailable =
        productVariation != null ? productVariation.id != null : true;
    print('couldBePurchased - isAvailable - $isAvailable - VariationTest');

    final isValidProductVariant = productVariation != null
        ? isValidProductVariation(variations!, mapAttribute)
        : true;
    print(
        'couldBePurchased - isValidProductVariant - $isValidProductVariant - VariationTest');

    final _isPurchased =
        isPurchased(productVariation, product, mapAttribute!, isAvailable);
    // const _isPurchased = true;
    print('couldBePurchased - _isPurchased - $_isPurchased - VariationTest');

    return isValidProductVariant && _isPurchased;
  }
  // ------

  /// Return true if mapAttribute match with any of variations.
  bool isValidProductVariation(
      List<ProductVariation> variations, Map<String?, String?>? mapAttribute) {
    print('Map Of Attrs: ${mapAttribute}');
    print('Map Of variations: ${variations.map((e) => e.attributeMap)}');
    for (var variation in variations) {
      if (variation.hasSameAttributes(mapAttribute!)) {
        /// Hide out of stock variation
        if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
            !variation.inStock!) {
          return false;
        }

        return true;
      }
    }
    return false;
  }

  void onSelectProductVariant({
    ProductAttribute? attr,
    String? val,
    List<ProductVariation>? variations,
    Map<String?, String?>? mapAttribute,
    Function? onFinish,
  }) {
    if (kProductDetail.hideInvalidAttributes) {
      final previousVal = mapAttribute![attr!.name];

      /// Unselect if option is selected.
      if (val.toString() == previousVal) {
        mapAttribute[attr.name] = null;
        final productVariation = updateVariation(variations!, mapAttribute);
        onFinish!(mapAttribute, productVariation);
        return;
      }
    }

    mapAttribute!.update(attr!.name, (value) => val.toString(),
        ifAbsent: () => val.toString());

    if (!isValidProductVariation(variations!, mapAttribute)) {
      /// Reset other choices
      mapAttribute.clear();
      mapAttribute[attr.name] = val.toString();
    }

    final productVariation = updateVariation(variations, mapAttribute);
    onFinish!(mapAttribute, productVariation);
  }

  List<Widget> getProductAttributeWidget(
    String lang,
    Product product,
    Map<String?, String?>? mapAttribute,
    Function onSelectProductVariant,
    List<ProductVariation> variations,
  ) {
    var listWidget = <Widget>[];
    print('mapAttribute: $mapAttribute');
    print('product.attributes: ${product.attributes}');

    final checkProductAttribute = product.attributes?.isNotEmpty ?? false;
    if (checkProductAttribute) {
      for (var attr in product.attributes!) {
        if (attr.name?.isNotEmpty ?? false) {

          var options =
              _getValidAttributeOptions(attr, mapAttribute!, variations);

          /// Deselect invalid option.
          if (options.isEmpty) {
            mapAttribute[attr.name] = null;
            options = _getValidAttributeOptions(attr, mapAttribute, variations);
          }

          var selectedValue = mapAttribute[attr.name] ?? '';

          final attrType = ProductVariantLayout[attr.cleanSlug ?? attr.name] ??
              ProductVariantLayout[attr.name!.toLowerCase()] ??
              'box';

          /// For product variation swatches (image)
          Map<String?, String?>? imageUrls;
          if (attrType == 'image') {
            imageUrls = {};
            attr.options!.forEach((option) {
              if (option['description'].toString().contains('http')) {
                imageUrls![option['name']] = option['description'];
              }
            });
          }
          print('options: ${options}');

          listWidget.add(
            BasicSelection(
              imageUrls: imageUrls,
              options: options,
              title: kProductVariantLanguage[lang] != null
                  ? kProductVariantLanguage[lang]
                          [attr.cleanSlug ?? attr.name] ??
                      kProductVariantLanguage[lang][attr.name!.toLowerCase()] ??
                      attr.name!.toLowerCase()
                  : attr.name!.toLowerCase(),
              type: attrType,
              value: selectedValue,
              onChanged: (val) => onSelectProductVariant(
                  attr: attr,
                  val: val,
                  mapAttribute: mapAttribute,
                  variations: variations),
            ),
          );
          listWidget.add(
            const SizedBox(height: 20.0),
          );
        }
      }
    }
    return listWidget;
  }

  List<Widget> getProductTitleWidget(BuildContext context,
      ProductVariation? productVariation, Product product) {
    final isAvailable =
        // ignore: unnecessary_null_comparison
        productVariation != null ? productVariation.id != null : true;
    return makeProductTitleWidget(
        context, productVariation, product, isAvailable);
  }

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
  ) {
    final isAvailable =
        couldBePurchased(variations, productVariation, product, mapAttribute);

    return makeBuyButtonWidget(
        context,
        productVariation,
        product,
        mapAttribute!,
        maxQuantity,
        quantity,
        addToCart,
        onChangeQuantity,
        isAvailable);
  }

  List<String> _getValidAttributeOptions(ProductAttribute attr,
      Map<String?, String?> mapAttribute, List<ProductVariation> variations) {
    return List<String>.from(
      attr.options!
          .map((e) {
            var copy = Map<String?, String?>.from(mapAttribute);
            copy[attr.name] = e['name'];

            if (kProductDetail.hideInvalidAttributes) {
              if (isValidProductVariation(variations, copy)) {
                return e['name'];
              }
              return null;
            } else {
              return e['name'];
            }
          })
          .toList()

          /// To filter null value.
          .whereType<String>(),
    );
  }
}
