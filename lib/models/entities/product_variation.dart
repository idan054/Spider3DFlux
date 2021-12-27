import '../../common/config.dart';
import '../../common/constants.dart';
import '../../services/service_config.dart';
import 'product.dart';
import 'product_attribute.dart';

class ProductVariation {
  String? id;
  String? sku;
  // String? sku ?? 'Mynull_sku';
  String? price;
  String? regularPrice;
  String? salePrice;
  String? dateOnSaleFrom;
  String? dateOnSaleTo;
  bool? onSale;
  bool? inStock;
  int? stockQuantity;
  String? imageFeature;
  List<Attribute> attributes = [];
  Map<String?, Attribute> attributeMap = {};

  ProductVariation();

  ProductVariation.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'].toString();
    price = parsedJson['price'].toString();
    regularPrice = parsedJson['regular_price'].toString();
    salePrice = parsedJson['sale_price'].toString();
    dateOnSaleFrom = parsedJson['date_on_sale_from'];
    dateOnSaleTo = parsedJson['date_on_sale_to'];
    onSale = parsedJson['on_sale'] ?? false;
    inStock = parsedJson['in_stock'];
    inStock! ? stockQuantity = parsedJson['stock_quantity'] : stockQuantity = 0;
    imageFeature = parsedJson['image']['src'];

    var attributeList = <Attribute>[];
    parsedJson['attributes']?.forEach((item) {
      final attribute = Attribute.fromJson(item);
      attributeList.add(attribute);
      attributeMap[attribute.name] = attribute ;
    });
    attributes = attributeList;
  }

  ProductVariation.fromMagentoJson(
      Map<String, dynamic> parsedJson, Product product) {
    var getCustomAttribute = (customAttributes, attribute) {
      String? value;
      if (customAttributes != null && customAttributes.length > 0) {
        for (var item in customAttributes) {
          if (item['attribute_code'] == attribute) {
            value = item['value'];
            break;
          }
        }
      }
      return value;
    };

    var getProductImageUrlByName = (domain, imageName) {
      return '$domain/pub/media/catalog/product/$imageName';
    };

    id = parsedJson['id'].toString();
    sku = parsedJson['sku'];

    final dateSaleFrom = getCustomAttribute(
        parsedJson['custom_attributes'], 'special_from_date');
    final dateSaleTo =
        getCustomAttribute(parsedJson['custom_attributes'], 'special_to_date');
    onSale = false;
    var pPrice = parsedJson['price'];
    var pSalePrice =
        getCustomAttribute(parsedJson['custom_attributes'], 'special_price');
    if (dateSaleFrom != null || dateSaleTo != null) {
      final now = DateTime.now();
      if (dateSaleFrom != null && dateSaleTo != null) {
        onSale = now.isAfter(DateTime.parse(dateSaleFrom)) &&
            now.isBefore(DateTime.parse(dateSaleTo));
      }
      if (dateSaleFrom != null && dateSaleTo == null) {
        onSale = now.isAfter(DateTime.parse(dateSaleFrom));
      }
      if (dateSaleFrom == null && dateSaleTo != null) {
        onSale = now.isBefore(DateTime.parse(dateSaleTo));
      }
      if (onSale! && pSalePrice != null) {
        pPrice = pSalePrice;
      }
    } else if (pSalePrice != null &&
        dateSaleFrom == null &&
        dateSaleTo == null) {
      onSale =
          double.parse("${parsedJson["price"]}") > double.parse('$pSalePrice');
      pPrice = pSalePrice;
    }

    price = '$pPrice';
    regularPrice = "${parsedJson["price"]}";
    salePrice = onSale! ? pSalePrice : price;

    inStock = parsedJson['status'] == 1;

    final imageUrl =
        getCustomAttribute(parsedJson['custom_attributes'], 'image');
    imageFeature = imageUrl != null
        ? getProductImageUrlByName(Config().url, imageUrl)
        : product.imageFeature;

    var attributeList = <Attribute>[];
    List attributesConfig =
        kAdvanceConfig['EnableAttributesConfigurableProduct'];
    attributesConfig.forEach((element) {
      final item = getCustomAttribute(parsedJson['custom_attributes'], element);
      if (item != null) {
        final attribute = Attribute.fromMagentoJson(
            {'value': item, 'attribute_code': element});
        attributeList.add(attribute);
        attributeMap[attribute.name] = attribute;
      }
    });
    attributes = attributeList;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'price': price,
      'regularPrice': regularPrice,
      'sale_price': salePrice,
      'date_on_sale_from': dateOnSaleFrom,
      'date_on_sale_to': dateOnSaleTo,
      'on_sale': onSale,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'image': {'src': imageFeature},
      'attributes': attributes.map((item) {
        return item.toJson();
      }).toList()
    };
  }

  ProductVariation.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      sku = json['sku'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      onSale = json['onSale'] ?? false;
      salePrice = json['salePrice'];
      dateOnSaleFrom = json['date_on_sale_from'];
      dateOnSaleTo = json['date_on_sale_to'];
      inStock = json['in_stock'];
      inStock! ? stockQuantity = json['stock_quantity'] : stockQuantity = 0;
      imageFeature = json['image']['src'];
      var attributeList = <Attribute>[];

      if (json['attributes'] != null) {
        for (var item in json['attributes']) {
          final attribute = Attribute.fromLocalJson(item);
          attributeList.add(attribute);
          attributeMap[attribute.name] = attribute;
        }
      }

      attributes = attributeList;
    } catch (e) {
      printLog(e.toString());
    }
  }

  ProductVariation.fromShopifyJson(Map<String, dynamic> parsedJson) {
    var priceV2 = parsedJson['priceV2'];
    var compareAtPriceV2 = parsedJson['compareAtPriceV2'];
    var compareAtPrice =
        compareAtPriceV2 != null ? compareAtPriceV2['amount'] : null;

    id = parsedJson['id'];
    price = priceV2 != null ? priceV2['amount'] : null;
    regularPrice = compareAtPrice ?? price;
    onSale = compareAtPrice != null && compareAtPrice != price;
    inStock = parsedJson['availableForSale'];
    salePrice = price;
    imageFeature = parsedJson['image']['src'];

    var attributeList = <Attribute>[];
    parsedJson['selectedOptions']?.forEach((item) {
      final attribute = Attribute.fromShopifyJson(item);
      attributeList.add(attribute);
      attributeMap[attribute.name] = attribute;
    });
    attributes = attributeList;
  }

  ProductVariation.fromPrestaJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    regularPrice =
        (double.parse((json['price'] ?? 0.0).toString())).toStringAsFixed(2);
    salePrice = (double.parse((json['wholesale_price'] ?? 0.0).toString()))
        .toStringAsFixed(2);
    price = (double.parse((json['wholesale_price'] ?? 0.0).toString()))
        .toStringAsFixed(2);
    if (salePrice != regularPrice) {
      onSale = true;
    } else {
      onSale = false;
    }
    stockQuantity =
        json['quantity'].isNotEmpty ? int.parse(json['quantity']) : 0;
    if (stockQuantity! > 0) {
      inStock = true;
    } else {
      inStock = false;
    }
    imageFeature = json['image'];
    var attributeList = <Attribute>[];
    json['attributes']?.forEach((item) {
      attributeList.add(Attribute.fromPrestaJson(item));
    });
    attributes = attributeList;
  }

  /// Get product ID from mix String productID-ProductVariantID
  static String? cleanProductVariantID(productString) {
    return productString.contains('-') ? productString.split('-')[1] : null;
  }

  /// Return true if [attributeMap] includes [attributes]
  bool hasSameAttributes(Map<String?, String?> attributes) {
    var isSame = true;
    final keys = attributes.keys.toList(growable: false);
    final values = attributes.values.toList(growable: false);
    for (var i = 0; i < attributes.length; i++) {
      if (attributeMap[keys[i]] == null || values[i] == null) {
        /// In case this attribute can be any option, don't need to check.
        continue;
      }
     // ;
     //  print( Uri.decodeComponent(attributeMap[keys[i]]!.option ?? ''));
      if (attributeMap[keys[i]]!.option != values[i]) {
        return isSame = false;
      }
    }
    return isSame;
  }
}
