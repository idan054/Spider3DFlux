// ignore_for_file: omit_local_variable_types

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fstore/services/https.dart';
import 'package:fstore/services/my_sendErrorEmail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show compute;
import 'package:quiver/strings.dart';
import 'dart:math';
import 'dart:math';
import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/booking/staff_booking_model.dart';
import '../../../models/entities/paging_response.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import '../../../services/index.dart';
import '../../../services/wordpress/blognews_api.dart';
import '../../../services/wordpress/wordpress_api.dart';
import 'woocommerce_api.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart' show compute;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/booking/staff_booking_model.dart';
import '../../../models/entities/paging_response.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import '../../../services/index.dart';
import '../../../services/wordpress/blognews_api.dart';
import '../../../services/wordpress/wordpress_api.dart';
import 'woocommerce_api.dart';
import 'dart:math';

// Lasted WooCommerce Version
class WooCommerce extends BaseServices {
  Map<String, dynamic>? configCache;
  late WooCommerceAPI wcApi;

  String? isSecure;
  String? url;
  String? myApiAuth;
  String? blogUrl;
  List<Category> categories = [];
  Map<String, Tag> tags = {};
  String? currentLanguage;
  Map<String, List<Product>> categoryCache = <String, List<Product>>{};

  @override
  BlogNewsApi? blogApi;
  WordPressApi? wordPressAPI;


  // var myApiAuth = 'Basic Y2tfN2EzZDVlNjBmOTdmOWYyM2I0OTZjNWRmNzZkZmVmOTNkYzBiYjZkYTpjc180NmM0OTBlYmYwM2JkMDNiZTQ1Nzc0NzVlNzc3Y2E3NTQwOGRkOGMz';
  void appConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig['blog'] ?? appConfig['url']);
    wordPressAPI = WordPressApi(appConfig['url']);
    wcApi = WooCommerceAPI(appConfig['url'], appConfig['consumerKey'],
        appConfig['consumerSecret']);
    isSecure = appConfig['url'].indexOf('https') != -1 ? '' : '&insecure=cool';
    url = appConfig['url'];
    myApiAuth = appConfig['myApiAuth'];
    blogUrl = appConfig['blog'] ?? url;
    configCache = null;
    categories = [];
    currentLanguage = null;
    categoryCache = <String, List<Product>>{};
  }

  Product jsonParser(item) {
    var product = Product.fromJson(item);
    if (item['store'] != null) {
      if (item['store']['errors'] == null) {
        product = Services().widget.updateProductObject(product, item);
      }
    }
    return product;
  }

  @override
  Future<List<BlogNews>> fetchBlogLayout({required config, lang}) async {
    try {
      var list = <BlogNews>[];

      var endPoint = 'posts?_embed';
      if (kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }
      if (config.containsKey('category')) {
        endPoint += "&categories=${config["category"]}";
      }
      if (config.containsKey('limit')) {
        endPoint += "&per_page=${config["limit"] ?? 20}";
      }

      var response = await blogApi!.getAsync(endPoint);

      for (var item in response) {
        // ignore: unnecessary_null_comparison
        if (BlogNews.fromJson(item) != null) {
          list.add(BlogNews.fromJson(item));
        }
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BlogNews> getPageById(int? pageId) async {
    var response = await blogApi!.getAsync('pages/$pageId?_embed');
    return BlogNews.fromJson(response);
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      if (categories.isNotEmpty && currentLanguage == lang) {
        return categories;
      }
      currentLanguage = lang;
      var list = <Category>[];
      var isEnd = false;
      var page = 1;

      while (!isEnd) {
        var categories = await getCategoriesByPage(lang: lang, page: page);
        if (categories.isEmpty) {
          isEnd = true;
        }
        page = page + 1;
        list = [...list, ...categories];
      }
      categories = list;
      return list;
    } catch (e) {
      return [];
      //rethrow;
    }
  }

  String kExcludedCategoryString = kExcludedCategory
      .toString()
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll(' ', '');

  Future<List<Category>> getCategoriesByPage({lang, page}) async {
    try {
      var url =
      // EXCLUDE:
      // Original: 'products/categories?exclude=$kExcludedCategory&per_page=100&page=$page&hide_empty=true';
      // Example Array: 'products/categories?exclude=2354,5251&per_page=100&page=$page&hide_empty=true';
      // Dynamic Array:
      // 'products/categories?exclude=$kExcludedCategoryString&per_page=100&page=$page&hide_empty=true';

      // INCLUDE:
      // Example Array: 'products/categories?include=2341,2352,2343,5249,4939,2342&per_page=100&page=$page&hide_empty=true';
      /* Dynamic Array: */ 'products/categories?include=$kExcludedCategoryString&per_page=100&page=$page&hide_empty=true';

      // NoFilter:
      // 'products/categories?&per_page=100&page=$page&hide_empty=true';
      if (lang != null && kAdvanceConfig['isMultiLanguages']) {
        url += '&lang=$lang';
      }
      var response = await wcApi.getAsync(url);
      // print("kExcludedCategory is $kExcludedCategory");
      // print("kExcludedCategoryString is $kExcludedCategoryString");
      return compute(CategoryModel.parseCategoryList, response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) async {
    try {
      var endpoint = 'products';
      if (userId != null) {
        endpoint += '?user_id=$userId';
      }
      var response = await wcApi.getAsync(endpoint);
      var list = <Product>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(jsonParser(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  // Options: date, id, include, title, slug, price, popularity and rating. Default is date
  // var myOrderBy = 'date'; // Shows Esun & Spider PLA 9/10 ⭐️
  // Options: asc and desc. Default is desc.
  var myOrderBy = 'date'; // my // Show the lasted items
  var myOrder = 'desc'; // my // Show the lasted items

  @override
  Future<List<Product>?> fetchProductsLayout({config, lang, userId}) async {
    try {
      print("part Completed: A-0");
      print("isCaching is ${kAdvanceConfig['isCaching']}");

      /// Load first page from cache.
      if (kAdvanceConfig['isCaching'] &&
          configCache != null &&
          (config['page'] == 1 || config['page'] == null)) {
        var obj;
        final horizontalLayout = configCache!['HorizonLayout'] as List?;
        print("part Completed: A-1");
        // print(horizontalLayout);
        print("part Completed: A-1.2");
        if (horizontalLayout != null) {
          print("part Completed: A-1.3A");
          obj = horizontalLayout.firstWhere(
                  (o) =>
              o['layout'] == config['layout'] &&
                  ((o['category'] != null &&
                      o['category'] == config['category']) ||
                      (o['tag'] != null && o['tag'] == config['tag'])),
              orElse: () => null);
          if (obj != null && obj['data'].length > 0) {
            print('Successfully Load first page from cache.');
            // print("My obj['data'] ${obj?['data']}");
            return obj?['data'];
          } else {
            // when null
            // print(obj); // null
            // print("My obj['data'] ${obj?['data']} - My Not using cache..");
          }
          ;
          //
        }
        print("part Completed: A-1.3B");
        final verticalLayout = configCache!['VerticalLayout'];
        if (verticalLayout != null &&
            verticalLayout['layout'] == config['layout'] &&
            ((verticalLayout['category'] != null &&
                verticalLayout['category'] == config['category']) ||
                (verticalLayout['tag'] != null &&
                    verticalLayout['tag'] == config['tag']))) {
          return verticalLayout['data'];
        }
        //

      }
      var endPoint = 'products?status=publish';
      if (kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }
      if (config.containsKey('category') && config['category'] != null) {
        // endPoint += '&orderby=title';
        endPoint += '&orderby=$myOrderBy';
        endPoint += '&order=$myOrder';
        endPoint += "&category=${config["category"]}";
        print('WEEEE0 ${config['category'].runtimeType}');
        if (config['category'] == 2352){ // if filaments - remove SARAF שרף
          endPoint += '&attribute=pa_%D7%A7%D7%95%D7%98%D7%A8-%D7%97%D7%95%D7%9E%D7%A8&attribute_term=5564';
        }

        // endPoint += '&min_price=1';
        endPoint += '&stock_status=instock';
      }
      if (config.containsKey('tag') && config['tag'] != null) {
        endPoint += "&tag=${config["tag"]}";
      }

      /// Add featured filter
      if (config.containsKey('featured') && config['featured'] != null) {
        endPoint += "&featured=${config["featured"]}";
      }

      // Add onSale filter
      // if (config.containsKey('onSale') && config['onSale'] != null) {
      //   endPoint += "&on_sale=${config["onSale"]}";
      // }

      if (config.containsKey('page')) {
        endPoint += "&page=${config["page"]}";
      }
      if (config.containsKey('limit')) {
        endPoint += "&per_page=${config["limit"] ?? ApiPageSize}";
      }
      if (userId != null) {
        endPoint += '&user_id=$userId';
      }

      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response['message'])) {
        printLog('WooCommerce Error: ' + response['message']);
        return [];
      }
      return ProductModel.parseProductList(response, config);
    } catch (e, trace) {
      print('Something WentWrong Load first page');
      printLog(trace.toString());
      printLog(e.toString());
      print('--------------');
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      return [];
    }
  }

  /// get all attribute_term for selected attribute for filter menu
  @override
  Future<List<SubAttribute>> getSubAttributes({int? id}) async {
    try {
      var list = <SubAttribute>[];

      for (var i = 1; i < 100; i++) {
        var subAttributes = await getSubAttributesByPage(id: id, page: i);
        if (subAttributes.isEmpty) {
          break;
        }
        list = list + subAttributes;
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SubAttribute>> getSubAttributesByPage({id, page}) async {
    try {
      var listAttributes = <SubAttribute>[];

      var url = 'products/attributes/$id/terms?per_page=100&page=$page';
      var response = await wcApi.getAsync(url);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (item['count'] > 0) {
            listAttributes.add(SubAttribute.fromJson(item));
          }
        }
        return listAttributes;
      }
    } catch (e) {
      rethrow;
    }
  }

  //get all attributes for filter menu
  @override
  Future<List<FilterAttribute>> getFilterAttributes() async {
    try {
      var list = <FilterAttribute>[];
      var endPoint = 'products/attributes';

      var response = await wcApi.getAsync(endPoint);

      for (var item in response) {
        list.add(FilterAttribute.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>?> fetchProductsByCategory(
      {categoryId,
        tagId,
        page = 1,
        minPrice = 1.0,
        maxPrice,
        orderBy,
        lang,
        order,
        attribute,
        attributeTerm,
        featured,
        onSale,
        listingLocation,
        userId}) async {
    try {
      var list = <Product>[];

      /// this cause a bug on Profile List
      /// we just allow cache if the totalItem = perPageItem otherwise, should reload
      if ((page == 0 || page == 1) &&
          categoryCache['$categoryId'] != null &&
          categoryCache['$categoryId']!.isNotEmpty &&
          featured == null &&
          onSale == null &&
          attributeTerm == null) {
        if (categoryCache['$categoryId']!.length == ApiPageSize) {
          return categoryCache['$categoryId'];
        }
      }

      var endPoint =
      // 'products?status=publish&per_page=$ApiPageSize&page=$page&skip_cache=0'; // Original. 0 is False
          'products?status=publish&per_page=$ApiPageSize&page=$page&skip_cache=1';
      if (kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }
      if (categoryId != null && categoryId != '-1' && categoryId != '0') {
        endPoint += '&category=$categoryId';
        print('WEEEE1 ${categoryId.runtimeType}');
        if (categoryId == '2352'){ // if filaments - remove SARAF שרף
          endPoint += '&attribute=pa_%D7%A7%D7%95%D7%98%D7%A8-%D7%97%D7%95%D7%9E%D7%A8&attribute_term=5564';
        }
      }
      if (tagId != null) {
        endPoint += '&tag=$tagId';
      }
      if (minPrice != null) {
        // if (minPrice == '0' || minPrice == 0.0 || minPrice == 0) {
        //   minPrice = 1.0;
        // } // my - To Remove 0₪ Products
        // endPoint += '&min_price=${(minPrice as double).toInt().toString()}';
        endPoint += '&min_price=${minPrice.toString()}';
      }
      if (maxPrice != null && maxPrice > 0) {
        // endPoint += '&max_price=${(maxPrice as double).toInt().toString()}';
        endPoint += '&max_price=${maxPrice.toString()}';
      }
      // if (orderBy != null) {
      // endPoint += '&orderby=$orderBy';
      // endPoint += '&orderby=popularity';
      endPoint += '&orderby=$myOrderBy';

      // endPoint += '&min_price=1';
      endPoint += '&stock_status=instock';
      // }

      // if (order != null) {
      //   endPoint += '&order=$order';
      endPoint += '&order=$myOrder'; // }
      if (featured != null) {
        endPoint += '&featured=$featured';
      }
      // if (onSale != null) {
      // endPoint += '&on_sale=$onSale';
      // }
      if (attribute != null && attributeTerm != null) {
        endPoint += '&attribute=$attribute&attribute_term=$attributeTerm';
      }
      // if (kAdvanceConfig['hideOutOfStock']) {
      // }
      if (userId != null) {
        endPoint += '&user_id=$userId';
      }

      printLog('-- fetchProductsByCategory --');
      // endPoint = 'products?status=publish&per_page=20&page=1&skip_cache=1&category=2352&min_price=0&max_price=500&attribute=pa_brand, pa_color&attribute_term=5000, 5358,5004&user_id=649&consumer_key=ck_be61455d30704ff30718f80b417dd41c320b0cb0&consumer_secret=cs_79c75a8e1c40acfe530e6254f3cbb61a2e01f872';
      // printLog('Endpoint is $endPoint'); // products?status=publish&per_page=20&page=1&skip_cache=1&category=5249&user_id=649
      var response = await wcApi.getAsync(endPoint, version: 3);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        var highest_price = 0.0;
        for (var item in response) {
          var product = jsonParser(item);

          if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
              !product.inStock!) {
            /// hideOutOfStock product
            continue;
          }

          if (categoryId != null) {
            product.categoryId = categoryId;
          }
          list.add(product);
          var product_price = double.tryParse(product.price ?? '0') ?? 0.0;
          if(product_price > highest_price){
            highest_price = double.parse(product.price ?? '0');
          };
          // print('highest_price = $highest_price');


          // print('myFilterDivision = $myFilterDivision');
          // print('myFilterDivision = ${myFilterDivision.runtimeType}');
        }

        // myMaxPriceFilter = highest_price; // Not in use.
        // print('myMaxPriceFilter = $myMaxPriceFilter');
        // print('myMaxPriceFilter = ${myMaxPriceFilter.runtimeType}');

        // print('productPrice_list (Max) ${productPrice_list}');
        // print('productPrice_list (Max) ${productPrice_list?.reduce(max)}');

        return list;
      }
    } catch (e, trace) {
      printLog(trace);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User?> loginFacebook({String? token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$url/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime'
      // ignore: prefer_single_quotes
          "&access_token=$token$isSecure";

      var response = await httpCache(endPoint.toUri()!);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String? token}) async {
    try {
      //var endPoint = "$url/wp-json/api/flutter_user/sms_login/?access_token=$token$isSecure";
      var endPoint =
      // ignore: prefer_single_quotes
          "$url/wp-json/api/flutter_user/firebase_sms_login?phone=$token$isSecure";

      var response = await httpCache(endPoint.toUri()!);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User?> loginApple({String? token}) async {
    try {
      var endPoint = '$url/wp-json/api/flutter_user/apple_login';

      var response = await httpPost(endPoint.toUri()!,
          body: convert.jsonEncode({'token': token}),
          headers: {'Authorization': '$myApiAuth',
            'Content-Type': 'application/json'});

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response =
      await wcApi.getAsync('products/$productId/reviews', version: 2);
      var list = <Review>[];
      if (response is Map && isNotBlank(response['message'])) {
        printLog("error in get reviews ${response}" );
        throw Exception(response['message']);
      } else {
        printLog("review received ${response}" );

        for (var item in response) {
          list.add(Review.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Null> createReview(
      {String? productId, Map<String, dynamic>? data, String? token}) async {

    try {
      data!["product_id"] = productId;
      var response =
      await wcApi.postAsync('products/reviews', data, version: 3);
      if (response is Map && isNotBlank(response['message'])) {
        printLog("error in creating review ${response}");
        throw Exception(response['message']);
      } else {
        printLog("review created ${response}");
        return;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
    //
    // try {
    //   data!['product_id'] = productId;
    //   final response = await httpPost(
    //       '$url/wp-json/api/flutter_woo/products/reviews'.toUri()!,
    //       body: convert.jsonEncode(data),
    //       headers: {'Authorization': '$myApiAuth','User-Cookie': token!, 'Content-Type': 'application/json'});
    //   var body = convert.jsonDecode(response.body);
    //   if (body['message'] == null) {
    //     return;
    //   } else {
    //     printLog("Error thrown for creating review ${response.body}");
    //     throw Exception(body['message']);
    //   }
    // } catch (e) {
    //   //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
    //   rethrow;
    // }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product,
      {String? lang = 'en'}) async {
    try {
      final list = <ProductVariation>[];
      var page = 1;

      while (true) {
        var endPoint =
            'products/${product.id}/variations?per_page=100&page=$page';
        if (kAdvanceConfig['isMultiLanguages']) {
          endPoint += '&lang=$lang';
        }

        var response = await wcApi.getAsync(endPoint);
        if (response is Map && isNotBlank(response['message'])) {
          throw Exception(response['message']);
        } else {
          for (var item in response) {
            if (item['visible']) {
              list.add(ProductVariation.fromJson(item));
            }
          }

          printLog('XXX');
          printLog(list.first.attributes);
          printLog(list.first.price);
          printLog('XXX');

          if (response is List && response.length < 100) {
            /// No more data.
            break;
          }

          /// Fetch next page.
          page++;
        }
      }

      return list;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel? cartModel,
        String? token,
        String? checkoutId,
        Store? store}) async {
    try {
      if (isBookingProduct(cartModel!)) {
        return getShippingMethodsByWooApi();
      }
      var params = Order().toJson(cartModel, null, false);
      if (kVendorConfig['DisableVendorShipping'] == false) {
        List line_items = params['line_items'];
        line_items.forEach((element) {
          final product = cartModel.item[element['product_id']];
          if ((store == null && product!.store == null) ||
              (store != null &&
                  product!.store != null &&
                  product.store!.id == store.id)) {
            params['line_items'] = [element];
          }
        });
      }
      var list = <ShippingMethod>[];
      final response = await httpPost(
          '$url/wp-json/api/flutter_woo/shipping_methods'.toUri()!,
          body: convert.jsonEncode(params),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(ShippingMethod.fromJson(item));
        }
        print("Body req: (shipping_methods)");
        print(convert.jsonEncode(params));
        print("Body resp: (shipping_methods)");
        print(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      if (list.isEmpty) {
        throw Exception(
            'Your selected address is not supported by any Shipping method, please update the billing address again!');
      }
      print("list = <ShippingMethod>[]");
      list.forEach((element) {
        // title: 'Credit card - iCredit',
        print('element');
        print("description: '${element.description}',");
        print("id: '${element.id}',");
        print("title: '${element.title}',");
        print("classCost: '${element.classCost}',");
        print("cost: '${element.cost}',");
        print("methodId: '${element.methodId}',");
        print("methodTitle: '${element.methodTitle}',");
        print("min_amount: '${element.min_amount}',");
      });
      return list;
    } catch (err) {
      rethrow;
    }
  }

  bool isBookingProduct(CartModel cartModel) {
    var isBooking = false;
    cartModel.productsInCart.keys.forEach((key) {
      var productId = Product.cleanProductID(key);
      var product = cartModel.item[productId]!;
      if (product.bookingInfo != null) {
        isBooking = true;
      }
    });
    return isBooking;
  }

  Future<List<ShippingMethod>> getShippingMethodsByWooApi() async {
    try {
      var list = <ShippingMethod>[];
      var response = await wcApi.getAsync('shipping/zones/1/methods');
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          var methodItem = {
            'id': item['instance_id'],
            'method_id': item['method_id'],
            'instance_id': item['instance_id'],
            'label': item['title'],
            'cost': item['settings']['cost'] != null &&
                item['settings']['cost']['value'] != null
                ? item['settings']['cost']['value']
                : 0,
            'shipping_tax': 0
          };
          list.add(ShippingMethod.fromJson(methodItem));
        }
      }
      if (list.isEmpty) {
        throw Exception(
            'Your selected address is not supported by any Shipping method, please update the billing address again!');
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel,
        ShippingMethod? shippingMethod,
        String? token}) async {
    try {
      if (isBookingProduct(cartModel!)) {
        return getPaymentMethodsByWooApi();
      }

      final params = Order().toJson(cartModel, null, false);

      var list = <PaymentMethod>[];
      final response = await httpPost(
          '$url/wp-json/api/flutter_woo/payment_methods'.toUri()!,
          body: convert.jsonEncode(params),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(PaymentMethod.fromJson(item));
        }
        print("Body req: (payment_methods)");
        print(convert.jsonEncode(params));
        print("Body resp: (payment_methods)");
        print(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  Future<List<PaymentMethod>> getPaymentMethodsByWooApi() async {
    try {
      var list = <PaymentMethod>[];
      var response = await wcApi.getAsync('payment_gateways');
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (item['enabled'] == true &&
              item['id'] != 'wc-appointment-gateway') {
            var methodItem = {
              'id': item['id'],
              'title': item['method_title'],
              'method_title': item['instance_id'],
              'description': item['description']
            };
            list.add(PaymentMethod.fromJson(methodItem));
          }
        }
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Order>> getMyOrders(
      {User? user, dynamic cursor}) async {
    try {
      var response = await wcApi.getAsync(
          'orders?customer=${user!.id}&per_page=100&page=$cursor&order=desc&orderby=id');
      var list = <Order>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(Order.fromJson(item));
        }
        return PagingResponse(data: list);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<OrderNote>> getOrderNote(
      {String? userId, String? orderId}) async {
    try {
      var response = await wcApi
          .getAsync('orders/$orderId/notes?type=customer');
      var list = <OrderNote>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          printLog(item.toString());
          if (item is Map && (item as Map<String, dynamic>).containsKey("customer_note") && item['customer_note'] == true) {
            /// it is possible to update to `any` note
            /// ref: https://woocommerce.github.io/woocommerce-rest-api-docs/#list-all-order-notes
            list.add(OrderNote.fromJson(item));
          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Order> createOrder( // # 1
          {CartModel? cartModel,
        UserModel? user,
        bool? paid,
        String? transactionId}) async {
    try {
      final params = Order()
          .toJson(cartModel!, user!.user != null ? user.user!.id : null, paid);
      if (transactionId != null) {
        params['transaction_id'] = transactionId;
      }
      print('paramss');
      print(params);
      print('paramss as body');
      print(convert.jsonEncode(params));

      var base64Str = EncodeUtils.encodeCookie(user.user!.cookie!);

      final response = await httpPost(
          '$url/wp-json/api/flutter_order/create?token=$base64Str&BOOP=lol'
              .toUri()!,
          // '$url/wp-json/api/flutter_order/create'.toUri()!,
          body: convert.jsonEncode(params),
          headers: {'Authorization': '$myApiAuth',
            'User-Cookie': user.user != null ? user.user!.cookie! : '',
            // 'User-Cookie': 'token=c3hhfDE2MzYxMDgxMTd8bG02cWtvMWY5WnhneEhMUmJhWEpMNE9RWERJVUZNZUlJWVJIMjEzS1BhQXwwYjhjZGVkZjU2MWZlOTljYmRlMGNmMjMxZGVjY2Y4NmI0OTA4OTA4ZTRlNzA2OTA4ZjIyMTAxNTBiNmI5NmNk',
            'Content-Type': 'application/json'
          });
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 201 && body['message'] == null) {
        if (cartModel.shippingMethod == null &&
            kPaymentConfig['EnableShipping']) {
          body['shipping_lines'][0]['method_title'] = null;
        }
        return Order.fromJson(body);
      } else {
        // throw Exception('XXX ${body['message']}');
        throw Exception('\nאירעה שגיאה, בבקשה התנתק והתחבר מחדש לחשבון.');
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) async {
    try {
      final response = await httpPut(
          '$url/wp-json/api/flutter_order/update/$orderId'.toUri()!,
          body: convert.jsonEncode({'status': status}),
          headers: token != null ? {'User-Cookie': token} : {});

      var body = convert.jsonDecode(response.body);
      if (body['message'] != null) {
        throw Exception(body['message']);
      } else {
        return Order.fromJson(body);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Order?> cancelOrder({Order? order, String? userCookie}) async {
    final newOrder = await Services()
        .api
        .updateOrder(order!.id, status: 'cancelled', token: userCookie);
    return newOrder;
  }

  @override
  Future<List<Product>> searchProducts({
    name,
    categoryId = '',
    categoryName,
    tag = '',
    attribute = '',
    attributeId = '',
    page,
    lang,
    listingLocation = '',
    userId,
  }) async {
    try {
      // var endPoint = 'products?status=publish&page=$page&per_page=$ApiPageSize'; //Original
      var endPoint = 'products?status=publish&page=$page&per_page=100';

      if ((lang?.isNotEmpty ?? false) && kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }

/*      if (categoryId != null) {
        endPoint += '&category=$categoryId';
      }

      if (attribute != null) {
        endPoint += '&attribute=$attribute';
      }

      if (attributeId != null) {
        endPoint += '&attribute_term=$attributeId';
      }

      if (tag != null) {
        endPoint += '&tag=$tag';
      }*/

      endPoint += '&min_price=1';
      endPoint += '&stock_status=instock';

      if (userId != null) {
        endPoint += '&user_id=$userId';
      }
      var response = await wcApi.getAsync('$endPoint&search=$name');
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        var list = <Product>[];
        for (var item in response) {
          if (!kAdvanceConfig['hideOutOfStock'] || item['in_stock']) {
            list.add(jsonParser(item));
          }
        }

        /// Search by SKU.
        if (kAdvanceConfig['EnableSkuSearch'] ?? false) {
          var skuList = <Product>[];
          var response = await wcApi.getAsync('$endPoint&sku=$name');
          if (response is List) {
            for (var item in response) {
              if (!kAdvanceConfig['hideOutOfStock'] || item['in_stock']) {
                skuList.add(jsonParser(item));
              }
            }

            if (skuList.isNotEmpty) {
              /// Merge results. Let SKU results on top.
              skuList.addAll(list);
              return skuList;
            }
          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  /// Auth
  @override
  Future<User?> getUserInfo(cookie) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(cookie);
      final response = await httpCache(
          '$url/wp-json/api/flutter_user/get_currentuserinfo?token=$base64Str&$isSecure'
              .toUri()!);
      final body = convert.jsonDecode(response.body);
      if (body['user'] != null) {
        var user = body['user'];
        return User.fromAuthUser(user, cookie);
      } else {
        if (body['message'] != 'Invalid cookie') {
          throw Exception(body['message']);
        }
        return null;

        /// we may handle if Invalid cookie here
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String? token) async {
    try {
      final body = convert.jsonEncode({...json, 'cookie': token});
      final response = await httpPost(
          '$url/wp-json/api/flutter_user/update_user_profile'.toUri()!,
          body: body,
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data['cookie'] = token;
        return data;
      } else {
        throw Exception('Can not update user infor');
      }
    } catch (err) {
      rethrow;
    }
  }

  /// Create a New User
  @override
  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      var niceName = firstName! + ' ' + lastName!;
      final response = await httpPost(
          '$url/wp-json/api/flutter_user/sign_up/?insecure=cool&$isSecure'
              .toUri()!,
          body: convert.jsonEncode({
            'user_email': username,
            'user_login': username,
            'username': username,
            'user_pass': password,
            'email': username,
            'user_nicename': niceName,
            'display_name': niceName,
            'phone': phoneNumber,
            'first_name': firstName,
            'last_name': lastName,
          }),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['message'] == null) {
        var cookie = body['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = body['message'];
        throw Exception(message ?? 'Can not create the user.');
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  /// login
  @override
  Future<User?> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final response = await httpPost(
          '$url/wp-json/api/flutter_user/generate_auth_cookie/?insecure=cool&$isSecure'
              .toUri()!,
          body: convert.jsonEncode({'seconds': cookieLifeTime.toString(), 'username': username, 'password': password}),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        return await getUserInfo(body['cookie']);
      } else {
        throw Exception('The username or password is incorrect.');
      }
    } catch (err, trace) {
      printLog('🔥 Integration error:');
      printLog(err);
      printLog(trace);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  Future<Stream<Product>> streamProductsLayout({required config}) async {
    try {
      var endPoint = 'products?per_page=$ApiPageSize';
      if (config.containsKey('category')) {
        endPoint += "&category=${config["category"]}";
        print('WEEEE2 ${config['category'].runtimeType}');
        if (config['category'] == 2352){ // if filaments - remove SARAF שרף
          endPoint += '&attribute=pa_%D7%A7%D7%95%D7%98%D7%A8-%D7%97%D7%95%D7%9E%D7%A8&attribute_term=5564';
        }
      }
      if (config.containsKey('tag')) {
        endPoint += "&tag=${config["tag"]}";
      }

      var response = await wcApi.getStream(endPoint);

      return response.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .expand((data) => (data as List))
          .map(jsonParser);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    try {
      var endpoint = (lang == null || !kAdvanceConfig['isMultiLanguages'])
          ? 'products/$id'
          : 'products/$id?lang=$lang';

      var response = await wcApi.getAsync(endpoint);
      return jsonParser(response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Coupons> getCoupons({int page = 1}) async {
    try {
      // var response = await wcApi.getAsync('coupons?page=$page');
      var response = await wcApi.getAsync('coupons?page=1&per_page=100');
      // printLog(response.toString());
      return Coupons.getListCoupons(response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<AfterShip> getAllTracking() async {
    final data = await httpCache(
        'https://api.aftership.com/v4/trackings'.toUri()!,
        headers: {'Authorization': '$myApiAuth','aftership-api-key': afterShip['api']});
    return AfterShip.fromJson(json.decode(data.body));
  }

  @override
  Future<Map<String, dynamic>?> getHomeCache(String? lang) async {
    try {
      final data = await wcApi.getAsync('flutter/cache?lang=$lang');
      if (data['message'] != null) {
        throw Exception(data['message']);
      }
      var config = data;
      if (config['HorizonLayout'] != null) {
        var horizontalLayout = config['HorizonLayout'] as List;
        List<dynamic>? items = [];
        List<dynamic>? products = [];
        List<Product> list;
        for (var i = 0; i < horizontalLayout.length; i++) {
          if (horizontalLayout[i]['radius'] != null) {
            horizontalLayout[i]['radius'] =
                double.parse("${horizontalLayout[i]["radius"]}");
          }
          if (horizontalLayout[i]['size'] != null) {
            horizontalLayout[i]['size'] =
                double.parse("${horizontalLayout[i]["size"]}");
          }
          if (horizontalLayout[i]['padding'] != null) {
            horizontalLayout[i]['padding'] =
                double.parse("${horizontalLayout[i]["padding"]}");
          }

          products = horizontalLayout[i]['data'] as List?;
          list = [];
          if (products != null && products.isNotEmpty) {
            for (var item in products) {
              var product = jsonParser(item);
              if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
                  !product.inStock!) {
                /// hideOutOfStock product
                continue;
              }
              if (horizontalLayout[i]['category'] != null &&
                  "${horizontalLayout[i]["category"]}".isNotEmpty) {
                product.categoryId = horizontalLayout[i]['category'].toString();
              }
              list.add(product);
            }
          }
          horizontalLayout[i]['data'] = list;

          items = horizontalLayout[i]['items'] as List?;
          if (items != null && items.isNotEmpty) {
            for (var j = 0; j < items.length; j++) {
              if (items[j]['padding'] != null) {
                items[j]['padding'] = double.parse("${items[j]["padding"]}");
              }

              var listProduct = <Product>[];
              var prods = items[j]['data'] as List?;
              if (prods != null && prods.isNotEmpty) {
                for (var prod in prods) {
                  var product = jsonParser(prod);
                  if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
                      !product.inStock!) {
                    /// hideOutOfStock product
                    continue;
                  }
                  listProduct.add(product);
                }
              }
              items[j]['data'] = listProduct;
            }
          }
        }

        if (config['VerticalLayout'] != null &&
            config['VerticalLayout']['data'] != null) {
          var products = config['VerticalLayout']['data'] as List?;
          var list = <Product>[];
          if (products != null && products.isNotEmpty) {
            for (var item in products) {
              var product = jsonParser(item);
              if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
                  !product.inStock!) {
                /// hideOutOfStock product
                continue;
              }
              list.add(product);
            }
          }
          config['VerticalLayout']['data'] = list;
        }
        configCache = config;
        return config;
      }
      return null;
    } catch (e, trace) {
      // printLog(trace);
      // printLog(e);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      return null;
    }
  }

  @override
  Future<User?> loginGoogle({String? token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
      '$url/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime'
          '&access_token=$token$isSecure'
          .toUri()!;

      var response = await httpCache(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  /// This layout only suitable for the small Categories items
  @override
  Future getCategoryWithCache() async {
    List<Category> getSubCategories(id) {
      return categories.where((o) => o.parent == id).toList();
    }

    bool hasChildren(id) {
      return categories.where((o) => o.parent == id).toList().isNotEmpty;
    }

    List<Category> getParentCategory() {
      return categories.where((item) => item.parent == '0').toList();
    }

    var categoryIds = <String>[];
    var parentCategories = getParentCategory();
    for (var item in parentCategories) {
      if (hasChildren(item.id)) {
        var subCategories = getSubCategories(item.id);
        for (var item in subCategories) {
          categoryIds.add(item.id.toString());
        }
      } else {
        categoryIds.add(item.id.toString());
      }
    }

    return await getCategoryCache(categoryIds);
  }

  Future<Map<String, dynamic>> getCategoryCache(categoryIds) async {
    try {
      final data = await wcApi.getAsync(
          'flutter/category/cache?categoryIds=${List<String>.from(categoryIds).join(",")}');
      if (data != null) {
        for (var i = 0; i < categoryIds.length; i++) {
          var productsJson = data['${categoryIds[i]}'] as List?;
          var list = <Product>[];
          if (productsJson != null && productsJson.isNotEmpty) {
            for (var item in productsJson) {
              var product = jsonParser(item);
              product.categoryId = categoryIds[i];
              list.add(product);
            }
          }
          categoryCache['${categoryIds[i]}'] = list;
        }
      }

      return categoryCache;
    } catch (e, trace) {
      // printLog(trace.toString());
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<FilterTag>> getFilterTags() async {
    try {
      var list = <FilterTag>[];
      var endPoint = 'products/tags';
      var response = await wcApi.getAsync(endPoint);

      for (var item in response) {
        list.add(FilterTag.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getCheckoutUrl(
      Map<String, dynamic> params, String? lang) async {
    try {
      var str = convert.jsonEncode(params);
      var bytes = convert.utf8.encode(str);
      var base64Str = convert.base64.encode(bytes);

      final response =
      await httpPost('$url/wp-json/api/flutter_user/checkout'.toUri()!,
          body: convert.jsonEncode({
            'order': base64Str,
          }),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body is String) {
        // print("flutter_user/checkout Body req:");
        // print(convert.jsonEncode({
        //   'order': base64Str,
        // }));
        // print("flutter_user/checkout Body resp:");
        // print(body);
        if (kPaymentConfig['EnableOnePageCheckout'] ||
            kPaymentConfig['NativeOnePageCheckout'] ||
            kPaymentConfig['GuestCheckout'] == true ||
            params['token'] == null) {
          // print("flutter_user/checkout Native / OnePage is enabled");
          Map<String, dynamic> checkoutPageSlug =
          kPaymentConfig['CheckoutPageSlug'];
          String? slug = checkoutPageSlug[lang!];
          slug ??= checkoutPageSlug.values.toList().first;
          slug = slug!.contains('?') ? slug + '&' : slug + '?';
          // printLog('$url/${slug}code=$body&mobile=true'); // I/flutter (20674): ℹ️[6:00:43-043ms]https://spider3d.co.il/checkout?code=d731aabe6316c96fc424959ed7d733cd&mobile=true
          return '$url/${slug}code=$body&mobile=true';
        } else {
          return '$url/mstore-checkout?code=$body&mobile=true';
        }
      } else {
        var message = body['message'];
        throw Exception(message ?? "Can't save the order to website");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String?> submitForgotPassword(
      {String? forgotPwLink, Map<String, dynamic>? data}) async {
    try {
      var endpoint = '$url/wp-json/api/flutter_user/reset-password'.toUri()!;
      var response = await httpPost(endpoint,
          body: convert.jsonEncode(data),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      var result = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return '';
      } else {
        return result['message'];
      }
    } catch (e) {
      printLog(e);
      return 'Unknown Error: $e';
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrencyRate() async {
    try {
      final response = await httpCache(
          '$url/wp-json/api/flutter_user/get_currency_rates'.toUri()!);
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body != null && body is Map) {
        var data = Map<String, dynamic>.from(body);
        var currency = <String, dynamic>{};
        data.keys.forEach((key) {
          currency[key.toUpperCase()] =
              double.parse("${data[key]['rate'] == 0 ? 1 : data[key]['rate']}");
        });
        return currency;
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

  @override
  Future getCountries() async {
    try {
      final response = await httpCache(
          '$url/wp-json/api/flutter_user/get_countries'.toUri()!);
      var body = convert.jsonDecode(response.body);
      return body;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future getStatesByCountryId(countryId) async {
    try {
      final response = await httpCache(
          '$url/wp-json/api/flutter_user/get_states?country_code=$countryId'
              .toUri()!);
      var body = convert.jsonDecode(response.body);
      return body;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>?>? getCartInfo(String? token) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(token!);

      final response = await httpCache(
          '$url/wp-json/api/flutter_woo/cart?token=$base64Str'.toUri()!);
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future syncCartToWebsite(CartModel cartModel, User? user) async {
    try {
      final params = Order()
          .toJson(cartModel, cartModel.user != null ? user!.id : null, false);

      final response = await httpPost(
          '$url/wp-json/api/flutter_woo/cart'.toUri()!,
          body: convert.jsonEncode(params),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerInfo(String? id) async {
    try {
      final response = await wcApi.getAsync('customers/$id');
      if (response['message'] != null) {
        throw Exception(response['message']);
      }
      if (response['billing'] != null) {
        final address = Address.fromJson(response);
        final billing = Address.fromJson(response['billing']);
        billing.firstName =
        billing.firstName!.isEmpty ? address.firstName : billing.firstName;
        billing.lastName =
        billing.lastName!.isEmpty ? address.lastName : billing.lastName;
        billing.email = billing.email!.isEmpty ? address.email : billing.email;
        if (billing.country!.isEmpty) {
          billing.country = kPaymentConfig['DefaultCountryISOCode'];
        }
        if (billing.state!.isEmpty) {
          billing.state = kPaymentConfig['DefaultStateISOCode'];
        }
        response['billing'] = billing;
      }
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getTaxes(CartModel cartModel) async {
    try {
      if (isBookingProduct(cartModel)) return null;
      final params = Order().toJson(
          cartModel, cartModel.user != null ? cartModel.user!.id : null, false);

      final response = await httpPost(
          '$url/wp-json/api/flutter_woo/taxes'.toUri()!,
          body: convert.jsonEncode(params),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        var taxes = <Tax>[];
        body['items'].forEach((item) {
          taxes.add(Tax.fromJson(item));
        });
        return {'items': taxes, 'total': body['taxes_total']};
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, Tag>> getTagsByPage({String? lang, int? page}) async {
    try {
      var url = 'products/tags?per_page=100&page=$page&hide_empty=true';
      if (lang != null && kAdvanceConfig['isMultiLanguages']) {
        url += '&lang=$lang';
      }
      var response = await wcApi.getAsync(url);

      return compute(TagModel.parseTagList, response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Map<String, Tag>> getTags({String? lang}) async {
    try {
      if (tags.isNotEmpty && currentLanguage == lang) {
        return tags;
      }
      currentLanguage = lang;
      var map = <String, Tag>{};
      var isEnd = false;
      var page = 1;

      while (!isEnd) {
        var _tags = await getTagsByPage(lang: lang, page: page);
        if (_tags.isEmpty) {
          isEnd = true;
        }
        page = page + 1;

        map.addAll(_tags);
      }
      tags = map;
      return tags;
    } catch (e, trace) {
      printLog(trace);
      return {};
      //rethrow;
    }
  }

  @override
  Future<bool> pushNotification(cookie,
      {receiverEmail, senderName, message}) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(cookie);
      final endpoint = '$url/wp-json/api/flutter_user/notification';
      final res = await httpPost(endpoint.toUri()!, body: {
        'token': base64Str,
        'receiver': receiverEmail,
        'sender': senderName,
        'message': message,
      });
      if (res.statusCode == 200) {
        return true;
      } else {
        throw Exception(res.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Order>>? getVendorOrders(
      {required User user, dynamic cursor = 1}) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(user.cookie!);
      final response = await httpCache(
          '$url/wp-json/wc/v2/flutter/vendor-orders?page=$cursor&per_page=25&token=$base64Str'
              .toUri()!);
      printLog(
          '$url/wp-json/wc/v2/flutter/vendor-orders?page=$cursor&token=$base64Str'
              .toUri());
      var body = convert.jsonDecode(response.body);
      var list = <Order>[];
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else {
        for (var item in body) {
          list.add(Order.fromJson(item));
        }
        return PagingResponse(data: list);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Product> createProduct(
      String? cookie, Map<String, dynamic> data) async {
    try {
      final response = await httpPost(
          '$url/wp-json/api/flutter_multi_vendor/product'.toUri()!,
          body: convert.jsonEncode(data),
          headers: {'Authorization': '$myApiAuth',
            'User-Cookie': cookie!,
            'Content-Type': 'application/json'
          });
      var body = convert.jsonDecode(response.body);
      if (body['message'] == null) {
        return jsonParser(body);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getOwnProducts(String? cookie,
      {int? page, int? perPage}) async {
    try {
      final response = await httpPost(
          '$url/wp-json/api/flutter_multi_vendor/products/owner'.toUri()!,
          body: convert.jsonEncode({'cookie': cookie, 'page': page}),
          headers: {'Authorization': '$myApiAuth',
            'User-Cookie': cookie!,
            'Content-Type': 'application/json'
          });
      var body = convert.jsonDecode(response.body);
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else {
        var list = <Product>[];
        for (var item in body) {
          list.add(jsonParser(item));
        }
        return list;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadImage(dynamic data, String? token) async {
    try {
      final response = await httpPost(
          '$url/wp-json/api/flutter_multi_vendor/media'.toUri()!,
          body: convert.jsonEncode(data),
          headers: {'Authorization': '$myApiAuth','User-Cookie': token!, 'Content-Type': 'application/json'});
      var body = convert.jsonDecode(response.body);
      if (body['message'] == null) {
        return body;
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Point?> getMyPoint(String? token) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(token!);
      final response = await httpCache(
          '$url/wp-json/api/flutter_woo/points?token=$base64Str'.toUri()!);
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Point.fromJson(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future updatePoints(String? token, Order? order) async {
    try {
      final response = await httpPatch(
          '$url/wp-json/api/flutter_woo/points'.toUri()!,
          body: convert.jsonEncode({'cookie': token, 'order_id': order!.id}));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<BookStatus>? bookService({userId, value, message}) => null;

  @override
  Future<List<Product>> getProductNearest(location) async {
    try {
      var list = <Product>[];
      var lat = location.latitude;
      var long = location.longitude;
      var urlReq =
          '$url/wp-json/wp/v2/${DataMapping().kProductPath}?status=publish&_embed=true';
      if (lat != 0 || long != 0) {
        urlReq += '&isGetLocate=true&lat=$lat&long=$long';
      }
      final response = await httpCache(urlReq.toUri()!);
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)) {
          var product = Product.fromListingJson(item);
          var _gallery = <String>[];
          for (var item in product.images) {
            if (!item.contains('http')) {
              var res =
              await httpCache('$url/wp-json/wp/v2/media/$item'.toUri()!);
              _gallery.add(convert.jsonDecode(res.body)['source_url']);
            } else {
              _gallery.add(item);
            }
          }
          product.images = _gallery;
          list.add(product);
        }
      }
      printLog('getProductNearest');
      return list;
    } catch (err) {
      printLog('err at getProductRecents func ${err.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<ListingBooking>> getBooking({userId, page, perPage}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> createBooking(dynamic booking) async {
    if (booking.isAvaliableOrder && booking.isEmpty == false) {
      final response = await httpPost(
          '$url/wp-json/api/flutter_booking/checkout'.toUri()!,
          body: convert.jsonEncode(booking.toJsonAPI()),
          headers: {'Authorization': '$myApiAuth','Content-Type': 'application/json'});

      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['appointment'] != null) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  @override
  Future<List<StaffBookingModel>> getListStaff(String? idProduct) async {
    final urlAPI = wcApi.getOAuthURLExternal(
        '$url/wp-json/api/flutter_booking/get_staffs?product_id=$idProduct');

    final response = await httpCache(urlAPI.toUri()!);

    var body = convert.jsonDecode(response.body);
    if (response.statusCode == 200) {
      final listStaff = <StaffBookingModel>[];
      if (body is List) {
        if (body.isNotEmpty) {
          body.forEach((staff) {
            if (staff != null) {
              listStaff.add(StaffBookingModel.fromJson(staff));
            }
          });
        }
      }
      return listStaff;
    } else {
      return [];
    }
  }

  @override
  Future<List<String>> getSlotBooking(
      String? idProduct, String idStaff, String date) async {
    var urlAPI =
        '$url/wp-json/api/flutter_booking/get_slots?product_id=$idProduct&date=$date';

    if ((idStaff.isNotEmpty) && idStaff != 'null') {
      urlAPI += '&staff_ids=$idStaff';
    }

    final response = await httpCache(urlAPI.toUri()!);
    if (response.body.isNotEmpty) {
      final listSlot = <String>[];
      final result = convert.jsonDecode(response.body);
      if (result is List) {
        result.forEach((item) {
          if (item?.isNotEmpty ?? false) {
            listSlot.add('$item');
          }
        });
      }
      return listSlot;
    }
    return <String>[];
  }

  @override
  Future<Map<String, dynamic>>? checkBookingAvailability({data}) => null;

  @override
  Future<List<Store>>? getNearbyStores(Prediction prediction) => null;

  @override
  Future<Prediction> getPlaceDetail(
      Prediction prediction, String? sessionToken) async {
    try {
      var endpoint = 'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=${prediction.placeId}'
          '&fields=geometry&key=${isIos ? kGoogleAPIKey['ios'] : kGoogleAPIKey['android']}'
          '&sessiontoken=$sessionToken';

      var response = await httpCache(endpoint.toUri()!);
      var result = convert.jsonDecode(response.body);
      var lat = result['result']['geometry']['location']['lat'].toString();
      var long = result['result']['geometry']['location']['lng'].toString();
      prediction.lat = lat;
      prediction.long = long;
    } catch (e) {
      printLog('getPlaceDetail: $e');
    }
    return prediction;
  }

  @override
  Future<List<Prediction>> getAutoCompletePlaces(
      String term, String? sessionToken) async {
    try {
      var endpoint =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=$term&key=${isIos ? kGoogleAPIKey['ios'] : kGoogleAPIKey['android']}'
          '&sessiontoken=$sessionToken';

      var response = await httpCache(endpoint.toUri()!);
      var result = convert.jsonDecode(response.body);
      var list = <Prediction>[];
      for (var item in result['predictions']) {
        list.add(Prediction.fromJson(item));
      }
      return list;
    } catch (e) {
      printLog('getAutoCompletePlaces: $e');
    }
    return [];
  }

  @override
  Future<List<dynamic>>? getLocations() => null;

  @override
  Future<PagingResponse<Blog>> getBlogs(dynamic cursor) async {
    try {
      final param = '_embed&page=$cursor';
      // if (categories != null) {
      //   param += '&categories=$categories';
      // }
      final response =
      await httpCache('$blogUrl/wp-json/wp/v2/posts?$param'.toUri()!);

      if (response.statusCode != 200) {
        return const PagingResponse();
      }

      List data = jsonDecode(response.body);

      return PagingResponse(data: data.map((e) => Blog.fromJson(e)).toList());
    } on Exception catch (_) {
      return const PagingResponse();
    }
  }

  @override
  Future<Product?> getProductByPermalink(BuildContext context, String productPermalink) async {
    try {
      final response = await httpCache(
          '$url/wp-json/api/flutter_woo/products/dynamic?url=$productPermalink'
              .toUri()!);

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonParser(body[0]);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (e, trace) {
      print('addToCart() Error caught, Sending Email with full details..');
      const snackBar = SnackBar(
          duration: Duration(seconds: 6),
          content: Text(
              'אופס! לא ניתן להגיע למוצר זה... השגיאה התקבלה אצלנו ותטופל. אנא חזור לדף הראשי!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      sendErrorMail(
          product_name: 'שגיאת לינק דינאמי',
          product_id: 'Spider link: $productPermalink',
          product_link: 'SpiderApp Full link: $url/wp-json/api/flutter_woo/products/dynamic?url=$productPermalink',
          err_details: e.toString(),
          err_trace: trace.toString());

      print('addToCart() Error caught: e: $e \n trace: $trace');
    }
  }
}

/// My woorewards API (Source: https://plugins.longwatchstudio.com/docs/woorewards-4/api/users-points/)
// Sample: https://spider3d.co.il/wp-json/woorewards/v1/pools?consumer_key=ck_be61455d30704ff30718f80b417dd41c320b0cb0&consumer_secret=cs_79c75a8e1c40acfe530e6254f3cbb61a2e01f872

// @override
// Future<User> loginSMS({String? token}) async {
//   try {
//     //var endPoint = "$url/wp-json/api/flutter_user/sms_login/?access_token=$token$isSecure";
//     var endPoint =
//         // ignore: prefer_single_quotes
//         "$url/wp-json/api/flutter_user/firebase_sms_login?phone=$token$isSecure";
//
//     var response = await httpCache(endPoint.toUri()!);
//
//     var jsonDecode = convert.jsonDecode(response.body);
//
//     if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
//       throw Exception(jsonDecode['message']);
//     }
//
//     return User.fromWooJson(jsonDecode);
//   } catch (e) {
//     //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
//     rethrow;
//   }
// }

// My
Future<String> iCreditGetUrl(
    {buyer_name, city, street, email, phone, total_price}) async {
  // print(buyer_name);
  // print(city);

  // var url = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/GetUrl'; // Test Url
  var url = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/GetUrl'; // Url

  var req = {
    // 'GroupPrivateToken': 'e7bc02ba-7551-4ec3-884a-3524ba958a41', // OLD
    'GroupPrivateToken': 'a46ff2a5-5456-4f45-8c9a-32dab1d2a9bd', // New
    // 'GroupPrivateToken': 'bb8a47ab-42e0-4b7f-ba08-72d55f2d9e41', // Test
    'Items': [
      {
        // 'Id': 1,
        'Quantity': 1,
        'UnitPrice': total_price,
        'Description': 'תשלום מאובטח ביישומון Spider3D'
      }
    ],
    // 'FailRedirectURL': 'String content',
    // 'Order': 'Woo order number?',

    // 'CustomerFirstName': 'עידן ביטון',
    'CustomerFirstName': '$buyer_name',
    'CustomerLastName': 'לקוח', // CAN'T be empty or only white space
    'City': '$city',
    'Address': '$street',
    'EmailAddress': '$email',
    'PhoneNumber': '$phone',

    'MaxPayments': 12,
    'RedirectURL': 'https://www.spider3d.co.il/%D7%AA%D7%95%D7%93%D7%94/',
    // spider3d.co.il/תודה
    // 'DisplayPayPalButton': 'true',
    'CreateToken': 'true'
  };

  var dio = Dio();
  final resp = await dio.post(url, data: req);

  // print(resp.data);
  // print(resp.data['PrivateSaleToken']);

  print('resp.requestOptions.data');
  print(resp.requestOptions.data);

  print('resp.data');
  print(resp.data);
  print('resp.data');
  return resp.data['URL'].toString();
}
