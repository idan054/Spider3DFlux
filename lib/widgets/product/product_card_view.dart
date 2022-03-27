import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/widgets/skeleton_widget/skeleton_widget.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, ProductVariation, RecentModel;
import '../../routes/flux_navigate.dart';
import '../../services/service_config.dart';
import '../common/sale_progress_bar.dart';
import '../common/start_rating.dart';
import 'dialog_add_to_cart.dart';
import 'heart_button.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  final double? width;
  final double? maxWidth;
  final double? marginRight;
  final kSize size;
  final bool showCart;
  final bool showHeart;
  final bool showProgressBar;
  final height;
  final bool hideDetail;
  final offset;
  final tablet;
  final double? ratioProductImage;
  final bool enableBottomAddToCart;
  ProductCard({
    required this.item,
    this.width,
    this.maxWidth,
    this.size = kSize.medium,
    this.showHeart = false,
    this.showCart = false,
    this.showProgressBar = false,
    this.height,
    this.offset,
    this.hideDetail = false,
    this.tablet,
    this.marginRight = 6.0,
    this.ratioProductImage = 1.2,
    this.enableBottomAddToCart = false,
  });

  void addToCart(BuildContext context) {
    final String Function(
            {dynamic context,
            dynamic isSaveLocal,
            Function notify,
            Map<String, dynamic> options,
            Product? product,
            int quantity,
            ProductVariation variation}) addProductToCart =
        Provider.of<CartModel>(context, listen: false).addProductToCart;
    if (enableBottomAddToCart) {
      DialogAddToCart.show(context, product: item);
    } else {
      var message = addProductToCart(product: item, context: context);
      _showFlashNotification(item, message, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context, listen: false).currencyCode;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    var salePercent = 0;

    double? regularPrice = 0.0;
    var productImage = width! * (ratioProductImage ?? 1.2);

    // ignore: unrelated_type_equality_checks
    if (item.regularPrice != null &&
        item.regularPrice!.isNotEmpty &&
        item.regularPrice != '0.0') {
      regularPrice = (double.tryParse(item.regularPrice.toString()));
    }

    final gauss = offset != null
        ? math.exp(-(math.pow(offset.abs() - 0.5, 2) / 0.08))
        : 0.0;

    /// Calculate the Sale price
    var isSale = (item.onSale ?? false) &&
        PriceTools.getPriceProductValue(item, currency, onSale: true) !=
            PriceTools.getPriceProductValue(item, currency, onSale: false);
    if (isSale && regularPrice != 0) {
      salePercent =
          (double.parse(item.salePrice!) - regularPrice!) * 100 ~/ regularPrice;
    }

    if (item.type == 'variable') {
      isSale = item.onSale ?? false;
    }

    if (hideDetail) {
      return _buildImageFeature(
        context,
        () => _onTapProduct(context),
      );
    }

    var priceProduct = PriceTools.getPriceProductValue(
      item,
      currency,
      onSale: true,
    );

    /// Sold by widget
    var _soldByStore = item.store != null && item.store!.name != ''
        ? Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Text(
              S.of(context).soldBy + ' ' + item.store!.name!,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          )
        : const SizedBox();

    /// product name
    Widget _productTitle = Text(
      item.name! + '\n',
      style: Theme.of(context).textTheme.subtitle1!.apply(
            fontSizeFactor: 0.9,
          ),
      maxLines: 2,
    );

    /// Show Cart button
    /// width on product page = 120, on main page = 180 (180 / 9 = 120 | 120 / 9 = 13)
    var myRadiusBasedWidth = width == 180 ? 20.0 : 18.0;
    Widget _showCart = (showCart &&
            !item.isEmptyProduct() &&
            item.inStock != null &&
            item.inStock! &&
            item.type != 'variable')
        ? CircleAvatar(
            // backgroundColor: Colors.white.withOpacity(0.3),
            backgroundColor: Colors.grey.withOpacity(0.07),
            // radius: 20, // Original
            radius: myRadiusBasedWidth,
            child: IconButton(
                color: Theme.of(context).accentColor.withOpacity(0.5),
                // color: Colors.black,
                // icon: Icon(Icons.add_shopping_cart, size: width! / 10 * 1.3),
                icon: const Icon(Icons.add_shopping_cart, size: 18, color: kColorSpiderRed),
                onPressed: () => addToCart(context)),

          )
        : Container(width: 30, height: 30);

    /// Product Pricing
    Widget _productPricing =
    Row(
      // crossAxisAlignment: WrapCrossAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.type == 'grouped'
              ? '${S.of(context).from} ${PriceTools.getPriceProduct(item, currencyRate, currency, onSale: true)}'
              : priceProduct == '0.0'
                  ? S.of(context).loading
                  : Config().isListingType
                      ? PriceTools.getCurrencyFormatted(
                          item.price ?? item.regularPrice ?? '0', null)!
                      : PriceTools.getPriceProduct(item, currencyRate, currency,
                          onSale: true)!,
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(
                fontWeight: FontWeight.w600,
              )
              .apply(fontSizeFactor: 0.8),
        ),

        /// Not show regular price for variant product (product.regularPrice = "").
        if (isSale && item.type != 'variable') ...[
          const SizedBox(width: 5),
          Text(
            item.type == 'grouped'
                ? ''
                : PriceTools.getPriceProduct(item, currencyRate, currency,
                    onSale: false)!,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(
                  // fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).accentColor.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                )
                .apply(fontSizeFactor: 0.8),
            // .apply(fontSizeFactor: 0.83),
          ),
        ],
      ],
    );

    /// Product Stock Status
    var _stockStatus = _buildStockStatus(context);

    /// product rating, Hide rating for onSale layout.
    var _rating = (kAdvanceConfig['EnableRating']) &&
            (kAdvanceConfig['hideEmptyProductListRating'] == false ||
                (item.ratingCount != null && item.ratingCount! > 0)) &&
            !(showProgressBar)
        ? SmoothStarRating(
            allowHalfRating: true,
            starCount: 5,
            rating: item.averageRating ?? 0.0,
            size: 10.0,
            color: kColorRatingStar,
            borderColor: kColorRatingStar,
            label: Text(
              item.ratingCount == 0 || item.ratingCount == null
                  ? ''
                  : '${item.ratingCount}',
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .apply(fontSizeFactor: 0.7),
            ),
            spacing: 0.0)
        : const SizedBox();

    /// Show Stock status & Rating
    Widget _productStockRating = Padding(
      padding: const EdgeInsets.all(0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _stockStatus,
                      _rating,
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            // Positioned( // Original Cart
            //   left: Directionality.of(context) == TextDirection.rtl ? 0 : null,
            //   right: Directionality.of(context) == TextDirection.rtl ? null : 0,
            //   top: -14,
            // child: _showCart,
            // )
          ],
        ),
      ),
    );

    Widget _productImage = Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius:
              BorderRadius.circular((kProductCard['borderRadius'] ?? 3) * 0.7),
          child: Container(
            constraints: BoxConstraints(maxHeight: productImage),
            child: Transform.translate(
              offset: Offset(18 * gauss, 0.0),
              child: _buildImageFeature(
                context,
                () => _onTapProduct(context),
              ),
            ),
          ),
        ),

        /// Not show sale percent for variant product (product.regularPrice = "").
        if (isSale &&
            (item.regularPrice?.isNotEmpty ?? false) &&
            regularPrice != null &&
            regularPrice != 0.0 &&
            item.type != 'variable')
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                  color: kColorSpiderRed.withOpacity(0.70),
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12))),
              child: Text(
                '$salePercent%',
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )
                    .apply(fontSizeFactor: 0.9),
              ),
            ),
          ),

        /// Show On Sale label for variant product.
        if (isSale && item.type == 'variable')
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: kColorSpiderRed.withOpacity(0.70),
                  borderRadius:
                      const BorderRadius.only(bottomRight: Radius.circular(8))),
              child: Text(
                S.of(context).onSale,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
      ],
    );

    Widget _productInfo = Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          if (!(kProductCard['hideTitle'] ?? false)) _productTitle,
          if (!(kProductCard['hideStore'] ?? false)) _soldByStore,
          const SizedBox(height: 5),
          if (!(kProductCard['hidePrice'] ?? false)) _productPricing,
          const SizedBox(height: 2),
          _productStockRating,
          // const SizedBox(height: 2),
        ],
      ),
      Positioned(
        left: Directionality.of(context) == TextDirection.rtl ? 0 : null,
        right: Directionality.of(context) == TextDirection.rtl ? null : 0,
        bottom: 0,
        // bottom: 20,
        child: _showCart,
      )
    ]);

    return GestureDetector(
      onTap: () => _onTapProduct(context),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth ?? width!),
              // constraints: const BoxConstraints(maxHeight: 600),
              width: width! - 6,
              decoration: BoxDecoration(
                boxShadow: [
                  if (kProductCard['boxShadow'] != null)
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(
                        kProductCard['boxShadow']['x'] ?? 0,
                        kProductCard['boxShadow']['y'] ?? 1,
                      ),
                      blurRadius: kProductCard['boxShadow']['blurRadius'] ?? 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(kProductCard['borderRadius'] ?? 3),
                child: Container(
                  // height: 500,
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _productImage,
                      _productInfo,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showHeart && !item.isEmptyProduct())
            Positioned(
              top: 5,
              right: 5,
              child: HeartButton(product: item, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildImageFeature(context, onTapProduct) {
    if (item.imageFeature != null &&
        item.imageFeature!.contains('placeholder')) {
      return Container(
        height: double.infinity * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: Text(
          item.name!,
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
      );
    }

    // config.image.toString().contains('http')
    //     ? ImageTools.image(
    //   fit: boxFit ?? BoxFit.fitWidth,
    //   url: config.image,
    // )
    //     : Image.asset(
    //   config.image,
    //   fit: boxFit ?? BoxFit.fitWidth,
    // ),

    /// temporary fix on CavansKit https://github.com/flutter/flutter/issues/49725
    // return GestureDetector(
    //   // onTap: onTapProduct,
    //   onTap: () => print(item.imageFeature.toString()),
    //   child: CachedNetworkImage(
    //     width: width,
    //     height: height,
    //     fit: kCardFit,
    //     imageUrl:
    //         '$kImageProxy${item.imageFeature.toString()}', // item.imageFeature.toString(),
    //     imageBuilder: (context, imageProvider) => Container(
    //       decoration: BoxDecoration(
    //         image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
    //       ),
    //     ),
    //     placeholder: (context, url) => CircularProgressIndicator(),
    //     errorWidget: (context, url, error) => Icon(Icons.error),
    //   ),
    // );
    //
    // return GestureDetector(
    // onTap: onTapProduct,
    // onTap: () => print(item.imageFeature.toString()),
    // child: ImageTools.image(
    //   fit: kCardFit,
    //   url: item.imageFeature.toString(),
    // ));


    /// Original:
    return GestureDetector(
      onTap: onTapProduct,
      child: ImageTools.image(
        /// Original card view
        url: item.imageFeature,
        width: width,
        size: kSize.medium,
        isResize: true,
        fit: kCardFit,
        offset: offset ?? 0.0,
      ),
    );
  }

  void _onTapProduct(context) {
    printLog("image is ${item.imageFeature}");
    if (item.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);
    //Load update product detail screen for FluxBuilder
    eventBus.fire(const EventDetailSettings());
    FluxNavigate.pushNamed(
      RouteList.productDetail,
      arguments: item,
    );
  }

  void _showFlashNotification(Product? product, String message, context) {
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
                product!.name!,
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

  Widget _buildStockStatus(BuildContext context) {
    if (showProgressBar) {
      return SaleProgressBar(width: width, product: item);
    }

    return (kAdvanceConfig['showStockStatus'] && !item.isEmptyProduct())
        ? item.backOrdered
            ? Text(
                '${S.of(context).backOrder}',
                style: const TextStyle(
                  color: kColorBackOrder,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              )
            : item.inStock != null
                ? Text(
                    item.inStock!
                        ? S.of(context).inStock
                        : S.of(context).outOfStock,
                    style: TextStyle(
                      color: item.inStock! ? kColorInStock : kColorOutOfStock,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  )
                : const SizedBox()
        : const SizedBox();
  }
}
