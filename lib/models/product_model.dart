import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../routes/flux_navigate.dart';
import '../screens/products/products_screen.dart';
import '../services/index.dart';
import 'entities/product.dart';
import 'entities/product_variation.dart';

class ProductModel with ChangeNotifier {
  final Services _service = Services();
  List<List<Product?>> products = [];
  String? message;

  /// current select product id/name
  String? categoryId;
  String? listingLocationId;
  String? categoryName;
  int? tagId;

  //list products for products screen
  bool isFetching = false;
  List<Product>? productsList;
  String? errMsg;
  bool? isEnd;

  ProductVariation? productVariation;
  List<Product>? lstGroupedProduct;
  String? cardPriceRange;
  String detailPriceRange = '';

  void changeProductVariation(ProductVariation? variation) {
    productVariation = variation;
    notifyListeners();
  }

  Future<List<Product>?> fetchGroupedProducts(
      {required Product product}) async {
    lstGroupedProduct = [];
    for (var productID in product.groupedProducts as Iterable<int>) {
      await _service.api.getProduct(productID)!.then((product) {
        if (product != null) {
          lstGroupedProduct!.add(product);
        }
      });
    }
    return lstGroupedProduct;
  }

  void changeDetailPriceRange(String? currency, Map<String, dynamic> rates) {
    if (lstGroupedProduct!.isNotEmpty) {
      var currentPrice = double.parse(lstGroupedProduct![0].price!);
      var max = currentPrice;
      var min = 0;
      for (var product in lstGroupedProduct!) {
        min = double.parse(product.price!).toInt();
        if (min > max) {
          var temp = min;
          max = min.toDouble();
          min = temp;
        }
        detailPriceRange = currentPrice != max
            ? '${PriceTools.getCurrencyFormatted(currentPrice, rates, currency: currency)} - ${PriceTools.getCurrencyFormatted(max, rates, currency: currency)}'
            : '${PriceTools.getCurrencyFormatted(currentPrice, rates, currency: currency)}';
      }
    }
  }

  Future<List<Product>?> fetchProductLayout(config, lang, {userId}) async {
    var myFetchProductLayout = _service.api
        .fetchProductsLayout(config: config, lang: lang, userId: userId);
    // print("myFetchProductLayout");
    // print(myFetchProductLayout);
    return myFetchProductLayout;
  }

  void fetchProductsByCategory({categoryId, categoryName, listingLocationId}) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    this.listingLocationId = listingLocationId;
    notifyListeners();
  }

  void updateTagId({tagId}) {
    this.tagId = tagId;
    notifyListeners();
  }

  Future<void> saveProducts(Map<String, dynamic> data) async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['home']!, data);
      }
    } catch (_) {}
  }

  Future<void> getProductsList({
    categoryId,
    minPrice,
    maxPrice,
    orderBy,
    order,
    String? tagId,
    lang,
    required page,
    featured,
    onSale,
    attribute,
    attributeTerm,
    listingLocation,
    userId,
  }) async {
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      if (tagId != null && tagId.isNotEmpty) {
        this.tagId = int.parse(tagId);
      }
      if (listingLocation != null) {
        listingLocationId = listingLocation;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final products = await _service.api.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        page: page,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm,
        listingLocation: listingLocation,
        userId: userId,
      );

      isEnd = products!.isEmpty || products.length < ApiPageSize;

      if (page == 0 || page == 1) {
        productsList = products;
      } else {
        productsList = [...productsList!, ...products];
      }

      isFetching = false;
      errMsg = null;

      notifyListeners();
    } catch (err, trace) {
      errMsg =
          'There is an issue with the app during request the data, please contact admin for fixing the issues ' +
              err.toString();
      isFetching = false;
      printLog(err);
      printLog(trace);
      notifyListeners();
    }
  }

  void setProductsList(List<Product> products) {
    productsList = products;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }

  Future<void> createProduct(
      List galleryImages,
      List<File> fileImages,
      String? cookie,
      String nameProduct,
      String? type,
      String? idCategory,
      double? salePrice,
      double regularPrice,
      String description) async {
    Future uploadImage() async {
      try {
        if (fileImages.isNotEmpty) {
          for (var i = 0; i < fileImages.length; i++) {
            printLog('path ${path.basename(fileImages[i].path)}');
            await _service.api.uploadImage({
              'title': {'rendered': path.basename(fileImages[i].path)},
              'media_attachment': base64.encode(fileImages[i].readAsBytesSync())
            }, cookie)!.then((photo) {
              galleryImages.add('${photo['id']}');
            });
          }
        } else {
          return;
        }
      } catch (e) {
        rethrow;
      }
    }

    await uploadImage().then((_) async {
      await _service.api.createProduct(cookie, {
        'title': nameProduct,
        'product_type': type,
        'content': description,
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'image_ids': galleryImages,
        'categories': [
          {'id': idCategory}
        ],
        'status': kNewProductStatus
      });
    });
  }

  /// Show the product list
  // ignore: missing_return
  static Future showList({
    cateId,
    cateName,
    String? tag,
    required BuildContext context,
    List<Product>? products,
    config,
    bool showCountdown = false,
    Duration countdownDuration = Duration.zero,
  }) async {
    const routeSetting = RouteSettings(name: RouteList.products);
    try {
      var categoryId = cateId ?? (config ?? {})['category']?.toString();
      var categoryName = cateName ?? (config ?? {})['name']?.toString();
      var listingLocationId = (config ?? {})['location']?.toString();
      final bool? onSale = config != null ? config['onSale'] : null;
      final bool? configCountdown = config != null
          ? config['showCountDown'] ?? false
          : kSaleOffProduct['ShowCountDown'];

      var tagId = tag ?? (config ?? {})['tag']?.toString();
      final productModel = Provider.of<ProductModel>(context, listen: false);

      if (kIsWeb || isDisplayDesktop(context)) {
        eventBus.fire(const EventCloseCustomDrawer());
      } else {
        eventBus.fire(const EventCloseNativeDrawer());
      }

      // for fetching beforehand
      if (categoryId != null || listingLocationId != null) {
        productModel.fetchProductsByCategory(
          categoryId: categoryId,
          categoryName: categoryName,
          listingLocationId: listingLocationId,
        );
      }

      /// for caching current products list from HomeCache
      if (products != null && products.isNotEmpty) {
        productModel.setProductsList(products);

        return FluxNavigate.push(MaterialPageRoute(
          settings: routeSetting,
          builder: (context) => ProductsScreen(
            products: products,
            categoryId: categoryId,
            tagId: tagId,
            onSale: onSale ?? false,
            listingLocation: listingLocationId,
            title: (onSale ?? false) && showCountdown ? categoryName : null,
            showCountdown:
                configCountdown! && (onSale ?? false) && showCountdown,
            countdownDuration: countdownDuration,
          ),
        ));
      }

      /// clear old products
      productModel.setProductsList([]);
      productModel.updateTagId(tagId: config != null ? config['tag'] : null);

      await FluxNavigate.push(MaterialPageRoute(
        settings: routeSetting,
        builder: (context) => ProductsScreen(
          products: products ?? [],
          categoryId: categoryId,
          tagId: tagId,
          onSale: onSale ?? false,
          title: (onSale ?? false) && showCountdown ? categoryName : null,
          showCountdown: configCountdown! && (onSale ?? false) && showCountdown,
          countdownDuration: countdownDuration,
          listingLocation: listingLocationId,
        ),
      ));
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  /// parse product from json
  static List<Product> parseProductList(response, config) {
    var list = <Product>[];
    if (response != null) {
      for (var item in response) {
        if ((kAdvanceConfig['hideOutOfStock'] ?? false) && !item['in_stock']) {
          /// hideOutOfStock product
          continue;
        }

        var product = Product.fromJson(item);

        if (config['category'] != null && "${config["category"]}".isNotEmpty) {
          product.categoryId = config['category'].toString();
        }
        if (item['store'] != null) {
          if (item['store']['errors'] != null) {
            list.add(product);
            continue;
          }
          product = Services().widget.updateProductObject(product, item);
        }
        list.add(product);
      }
    }
    return list;
  }
}
