import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fstore/modules/dynamic_layout/config/product_config.dart';
import 'package:fstore/modules/dynamic_layout/dynamic_layout.dart';
import 'package:fstore/modules/dynamic_layout/product/product_list.dart';
import 'package:fstore/modules/dynamic_layout/vertical/vertical.dart';
import 'package:fstore/widgets/home/index.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart' show Product, ProductModel, UserModel;
// import '../../../modules/booking/booking.dart';
import '../../../services/index.dart';
import '../../../widgets/product/heart_button.dart';
import '../../../widgets/product/product_bottom_sheet.dart';
import '../../custom/vendor_chat.dart';
import '../product_detail_screen.dart';
import '../widgets/index.dart';

class SimpleLayout extends StatefulWidget {
  final Product product;
  final bool isLoading;

  SimpleLayout({required this.product, this.isLoading = false});

  @override
  _SimpleLayoutState createState() => _SimpleLayoutState(product: product);
}

class _SimpleLayoutState extends State<SimpleLayout>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late Product product;
  String? selectedUrl;

  bool isVideoSelected = false;

  _SimpleLayoutState({required this.product});

  Map<String, String> mapAttribute = HashMap();
  var _hideController;
  var top = 0.0;

  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    // myVertical_config is base MainPage config
    // Sample: {key: r09jo0owu6, layout: menu, name: קטגוריות מובילות, isVertical: true, type: vertical}
    myVertical_config['name'] = 'מוצרים נוספים בקטגוריה';
    myVertical_config['layout'] = 'columns';
    myVertical_config['category'] = product.categoryId;
  }

  @override
  void didUpdateWidget(SimpleLayout oldWidget) {
    if (oldWidget.product.type != widget.product.type) {
      setState(() {
        product = widget.product;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Render product default: booking, group, variant, simple, booking
  Widget renderProductInfo() {
    var body;

    if (widget.isLoading == true) {
      body = kLoadingWidget(context);
    } else {
      switch (product.type) {
        // case 'appointment':
        //   return ProductBookingLayout(
        //     key: ValueKey('keyProductBooking${product.id}'),
        //     product: product,
        //   );
        case 'booking':
          body = ListingBooking(product);
          break;
        case 'grouped':
          body = GroupedProduct(product);
          break;
        default:
          body = ProductVariant(
            product,
            onSelectVariantImage: (String url) {
              setState(() {
                selectedUrl = url;
                isVideoSelected = false;
              });
            },
          );
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthHeight = size.height;
    // Map<String, dynamic> my_dict = {'name': 'Recent View', 'layout': 'recentView'},

    final userModel = Provider.of<UserModel>(context, listen: false);
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        bottom: false,
        top: kProductDetail.safeArea,
        child: ChangeNotifierProvider(
          create: (_) => ProductModel(),
          child: Stack(
            children: <Widget>[
              Scaffold(
                floatingActionButton: (!Config().isVendorType() ||
                        !kConfigChat['EnableSmartChat'])
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: VendorChat(
                          user: userModel.user,
                          store: product.store,
                        ),
                      ),
                backgroundColor: Theme.of(context).backgroundColor,
                body: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      brightness: Theme.of(context).brightness,
                      backgroundColor: Theme.of(context).backgroundColor,
                      elevation: 1,
                      expandedHeight:
                          kIsWeb ? 0 : widthHeight * kProductDetail.height,
                      pinned: false,
                      floating: false,
                      leading: Padding(
                        padding: const EdgeInsets.all(8),
                        // padding: const EdgeInsets.only(top: 8, left: 8,right: 8),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[100]!.withOpacity(0.75),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              // color: kGrey400,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.75),
                            ),
                            onPressed: () {
                              Provider.of<ProductModel>(context, listen: false)
                                  .changeProductVariation(null);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        if (widget.isLoading != true)
                          HeartButton(
                            product: product,
                            size: 18.0,
                            color: kGrey400,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            backgroundColor:
                                Colors.grey[100]!.withOpacity(0.75),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: IconButton(
                                icon: Icon(Icons.reply),
                                // color: kGrey400,
                                color: kColorSpiderRed, // Theme.of(context).accentColor.withOpacity(0.75),
                                onPressed: () =>
                                // open menu
                                //     ProductDetailScreen.showMenu(
                                //     context, widget.product,
                                //     isLoading: widget.isLoading),
                                Services().firebase.shareDynamicLinkProduct(
                                  context: context,
                                  productUrl: product.permalink,
                                  productId: product.id,
                                )
                              ),
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: kIsWeb
                          ? Container()
                          : Material(
                              elevation: 3,
                              child:
                                  _renderSelectedMedia(context, product, size)),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          const SizedBox(
                            height: 2,
                          ),
                          ProductGallery(
                            product: product,
                            onSelect: (String url, bool isVideo) {
                              if (mounted) {
                                setState(() {
                                  selectedUrl = url;
                                  isVideoSelected = isVideo;
                                });
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 4.0,
                              left: 15,
                              right: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                product.type == 'grouped'
                                    ? Container()
                                    : Builder(
                                      builder: (context) {

                                        return ProductTitle(product);
                                      }
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    renderProductInfo(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 15.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Column(
                                children: [
                                  Services().widget.renderVendorInfo(product),
                                  ProductDescription(product),
                                  if (kProductDetail.showProductCategories)
                                    ProductDetailCategories(product),
                                  if (kProductDetail.showProductTags)
                                    ProductTag(product),
                                ],
                              ),
                            ),
                            RelatedProduct(product),
                            /*                           ProductList( // נצפו לאחרונה
                                // config: ProductConfig.fromJson(config),
                                // key: config['key'] != null ? Key(config['key']) : UniqueKey()),
                                config:
                                    ProductConfig.fromJson(myRecentView_config),
                                key: UniqueKey()),*/
                            VerticalLayout(
                              config: myVertical_config,
                              key: UniqueKey(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ExpandingBottomSheet(
                  hideController: _hideController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderSelectedMedia(
      BuildContext context, Product? product, Size size) {
    /// Render selected video
    if (selectedUrl != null && isVideoSelected) {
      return FeatureVideoPlayer(
        url: selectedUrl!.replaceAll('http://', 'https://'),
        autoPlay: true,
      );
    }

    /// Render selected image from the Gallery
    if (selectedUrl != null &&
        !isVideoSelected &&
        (kProductDetail.showSelectedImageVariant)) {
      return GestureDetector(
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              var images = product?.images ?? <String>[];
              final index = images.indexOf(selectedUrl!);
              if (index == -1) {
                images.insert(0, selectedUrl!);
              }
              return ImageGalery(
                images: images,
                index: index == -1 ? 0 : index,
              );
            },
          );
        },
        child: ImageTools.image(
          url: selectedUrl,
          fit: BoxFit.contain,
          width: size.width,
          size: kSize.large,
          hidePlaceHolder: true,
          forceWhiteBackground: kProductDetail.forceWhiteBackground,
        ),
      );
    }

    /// Render default feature image
    return product!.type == 'variable'
        ? VariantImageFeature(product)
        : ImageFeature(product);
  }
}
