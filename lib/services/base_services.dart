import 'dart:async';
import 'dart:convert';

import 'package:http_auth/http_auth.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../models/entities/paging_response.dart';
import '../models/entities/prediction.dart';
import '../models/index.dart';
import 'wordpress/blognews_api.dart';

export '../models/entities/paging_response.dart';

abstract class BaseServices {
  BlogNewsApi? blogApi;

  Future<List<Category>?>? getCategories({lang}) => null;

  Future<List<Product>>? getProducts({userId}) => null;

  Future<List<Product>?> fetchProductsLayout({required config, lang, userId});

  Future<List<Product>?> fetchProductsByCategory({
    categoryId,
    tagId,
    required page,
    minPrice,
    maxPrice,
    orderBy,
    lang,
    order,
    featured,
    onSale,
    attribute,
    attributeTerm,
    listingLocation,
    userId,
  });

  Future<User?>? loginFacebook({String? token}) => null;

  Future<User>? loginSMS({String? token}) => null;

  Future<User?>? loginApple({String? token}) => null;

  Future<User?>? loginGoogle({String? token}) => null;

  Future<List<Review>>? getReviews(productId) => null;

  Future<List<ProductVariation>?>? getProductVariations(Product product,
          {String? lang}) =>
      null;

  Future<List<ShippingMethod>>? getShippingMethods(
          {CartModel? cartModel,
          String? token,
          String? checkoutId,
          Store? store}) =>
      null;

  Future<List<PaymentMethod>>? getPaymentMethods({
    CartModel? cartModel,
    ShippingMethod? shippingMethod,
    String? token,
  }) =>
      null;

  Future<Order>? createOrder({
    CartModel? cartModel,
    UserModel? user,
    bool? paid,
    String? transactionId,
  }) =>
      null;

  Future<PagingResponse<Order>>? getMyOrders({
    User? user,
    dynamic cursor,
  }) =>
      null;

  Future? updateOrder(orderId, {status, required token}) => null;

  Future<Order?>? cancelOrder({
    required Order? order,
    required String? userCookie,
  }) =>
      null;

  Future<List<Product>>? searchProducts({
    name,
    categoryId,
    categoryName,
    tag,
    attribute,
    attributeId,
    required page,
    lang,
    listingLocation,
    userId,
  }) =>
      null;

  Future<User?>? getUserInfo(cookie) => null;

  Future<User?>? createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
  }) =>
      null;

  Future<Map<String, dynamic>?>? updateUserInfo(
          Map<String, dynamic> json, String? token) =>
      null;

  Future<User?>? login({
    username,
    password,
  }) =>
      null;

  Future<Product?>? getProduct(id, {lang}) => null;

  Future<Coupons>? getCoupons({int page = 1}) => null;

  Future<AfterShip>? getAllTracking() => null;

  Future<List<OrderNote>>? getOrderNote({
    String? userId,
    String? orderId,
  }) =>
      null;

  Future<Null>? createReview(
          {String? productId, Map<String, dynamic>? data, String? token}) =>
      null;

  Future<Map<String, dynamic>?>? getHomeCache(String? lang) => null;

  Future<List<BlogNews>>? fetchBlogLayout({required config, lang}) => null;

  Future<BlogNews>? getPageById(int? pageId) => null;

  Future? getCategoryWithCache() => null;

  Future<List<FilterAttribute>>? getFilterAttributes() => null;

  Future<List<SubAttribute>>? getSubAttributes({int? id}) => null;

  Future<List<FilterTag>>? getFilterTags() => null;

  Future<String>? getCheckoutUrl(Map<String, dynamic> params, String? lang) =>
      null;

  Future<String?>? submitForgotPassword({
    String? forgotPwLink,
    Map<String, dynamic>? data,
  }) =>
      null;

  Future? logout() => null;

  Future? checkoutWithCreditCard(String? vaultId, CartModel cartModel,
      Address address, PaymentSettingsModel paymentSettingsModel) {
    return null;
  }

  Future<PaymentSettings>? getPaymentSettings() {
    return null;
  }

  Future<PaymentSettings>? addCreditCard(
      PaymentSettingsModel paymentSettingsModel,
      CreditCardModel creditCardModel) {
    return null;
  }

  Future<Map<String, dynamic>?>? getCurrencyRate() => null;

  Future<List<dynamic>?>? getCartInfo(String? token) => null;

  Future? syncCartToWebsite(CartModel cartModel, User? user) => null;

  Future<Map<String, dynamic>>? getCustomerInfo(String? id) => null;

  Future<Map<String, dynamic>?>? getTaxes(CartModel cartModel) => null;

  Future<Map<String, Tag>>? getTags({String? lang}) => null;

  Future? getCountries() => null;

  Future? getStatesByCountryId(countryId) => null;

  Future<Point?>? getMyPoint(String? token) => null;

  Future? updatePoints(String? token, Order? order) => null;

  //For vendor
  Future<Store?>? getStoreInfo(storeId) => null;

  Future<bool>? pushNotification(
    cookie, {
    receiverEmail,
    senderName,
    message,
  }) =>
      null;

  Future<List<Review>>? getReviewsStore({storeId}) => null;

  Future<List<Product>>? getProductsByStore({
    storeId,
    page,
  }) =>
      null;

  Future<List<Store>>? searchStores({
    String? keyword,
    int? page,
  }) =>
      null;

  Future<List<Store>>? getFeaturedStores() => null;

  Future<PagingResponse<Order>>? getVendorOrders({
    required User user,
    dynamic cursor,
  }) =>
      null;

  Future<Product>? createProduct(String? cookie, Map<String, dynamic> data) =>
      null;

  Future<List<Product>>? getOwnProducts(
    String? cookie, {
    int? page,
    int? perPage,
  }) =>
      null;

  Future<dynamic>? uploadImage(dynamic data, String? token) => null;

  Future<List<Prediction>>? getAutoCompletePlaces(
          String term, String? sessionToken) =>
      null;

  Future<Prediction>? getPlaceDetail(
          Prediction prediction, String? sessionToken) =>
      null;

  Future<List<Store>>? getNearbyStores(Prediction prediction) => null;

  Future<Product?> getProductByPermalink(String productPermalink) async {}

  ///----FLUXSTORE LISTING----///
  Future<dynamic>? bookService({userId, value, message}) => null;

  Future<List<Product>>? getProductNearest(location) => null;

  Future<List<ListingBooking>>? getBooking({userId, page, perPage}) => null;

  Future<Map<String, dynamic>?>? checkBookingAvailability({data}) => null;

  Future<List<dynamic>>? getLocations() => null;

  /// BOOKING FEATURE
  Future<bool>? createBooking(dynamic bookingInfo) => null;

  Future<List<dynamic>>? getListStaff(String? idProduct) => null;

  Future<List<String>>? getSlotBooking(
          String? idProduct, String idStaff, String date) =>
      null;

  Future<PagingResponse<Blog>>? getBlogs(dynamic cursor) => null;

  /// RAZORPAY PAYMENT
  Future<String?> createRazorpayOrder(params) async {
    try {
      var client =
          BasicAuthClient(RazorpayConfig['keyId'], RazorpayConfig['keySecret']);
      final response = await client
          .post('https://api.razorpay.com/v1/orders'.toUri()!, body: params);
      final responseJson = jsonDecode(response.body);
      if (responseJson != null && responseJson['id'] != null) {
        return responseJson['id'];
      } else if (responseJson['message'] != null) {
        throw responseJson['message'];
      } else {
        throw "Can't create order for Razorpay";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrderIdForRazorpay(paymentId, orderId) async {
    try {
      final token = base64.encode(latin1
          .encode('${RazorpayConfig['keyId']}:${RazorpayConfig['keySecret']}'));

      final body = {
        'notes': {'woocommerce_order_id': orderId}
      };
      await httpPatch(
          'https://api.razorpay.com/v1/payments/$paymentId'.toUri()!,
          headers: {
            'Authorization': 'Basic ' + token.trim(),
            'Content-Type': 'application/json'
          },
          body: json.encode(body));
    } catch (e) {
      return;
    }
  }
}
